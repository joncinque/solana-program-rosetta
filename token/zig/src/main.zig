const sol = @import("solana_program_sdk");
const Account = sol.account.Account;
const PublicKey = sol.public_key.PublicKey;
const Rent = sol.rent.Rent;

const ix = @import("instruction.zig");
const state = @import("state.zig");
const TokenError = @import("error.zig").TokenError;
const native_mint_id = @import("id.zig").native_mint_id;
const system_program_id = @import("id.zig").system_program_id;

export fn entrypoint(input: [*]u8) u64 {
    var context = sol.context.Context.load(input) catch return 1;
    processInstruction(context.program_id, context.accounts[0..context.num_accounts], context.data) catch |err| return @intFromError(err);
    return 0;
}

fn initializeMint(accounts: []Account, data: []const u8) TokenError!void {
    if (accounts.len < 2) {
        return TokenError.NotEnoughAccountKeys;
    }
    const ix_data: *align(1) const ix.InitializeMintData = @ptrCast(data[1..]);
    const mint_account = accounts[0];
    const rent_sysvar = accounts[1];

    var mint: *align(1) state.Mint = @ptrCast(mint_account.data());
    if (mint_account.dataLen() != state.Mint.len) {
        return TokenError.InvalidAccountData;
    }
    if (mint.is_initialized == 1) {
        return TokenError.AlreadyInUse;
    }

    const rent: *align(1) Rent.Data = @ptrCast(rent_sysvar.data());
    if (!rent_sysvar.id().equals(Rent.id)) {
        return TokenError.InvalidAccountData;
    }
    if (!rent.isExempt(mint_account.lamports().*, mint_account.dataLen())) {
        return TokenError.NotRentExempt;
    }

    mint.mint_authority = state.COption(PublicKey).fromValue(ix_data.mint_authority);
    mint.decimals = ix_data.decimals;
    mint.is_initialized = 1;
    mint.freeze_authority = ix_data.freeze_authority.toCOption();
}

fn initializeAccount(program_id: *align(1) PublicKey, accounts: []Account) TokenError!void {
    if (accounts.len < 4) {
        return TokenError.NotEnoughAccountKeys;
    }
    const token_account = accounts[0];
    const mint_account = accounts[1];
    const owner = accounts[2];
    const rent_sysvar = accounts[3];
    const rent: *align(1) Rent.Data = @ptrCast(rent_sysvar.data());

    var account: *align(1) state.Account = @ptrCast(token_account.data());
    if (token_account.dataLen() != state.Account.len) {
        return TokenError.InvalidAccountData;
    }
    if (account.state != state.Account.State.uninitialized) {
        return TokenError.AlreadyInUse;
    }
    if (!rent.isExempt(token_account.lamports().*, token_account.dataLen())) {
        return TokenError.NotRentExempt;
    }

    account.mint = mint_account.id();
    account.owner = owner.id();
    //account.close_authority = state.COption(PublicKey).asNull();
    //account.delegate = state.COption(PublicKey).asNull();
    //account.delegated_amount = 0;
    account.state = state.Account.State.initialized;
    if (mint_account.id().equals(native_mint_id)) {
        const rent_exempt_reserve = rent.getMinimumBalance(token_account.dataLen());
        account.is_native = state.COption(u64).fromValue(rent_exempt_reserve);
        if (rent_exempt_reserve > token_account.lamports().*) {
            return TokenError.Overflow;
        }
        account.amount = token_account.lamports().* - rent_exempt_reserve;
    } else {
        if (!mint_account.ownerId().equals(program_id.*)) {
            return TokenError.IllegalOwner;
        }
        const mint: *align(1) state.Mint = @ptrCast(mint_account.data());
        if (mint_account.dataLen() != state.Mint.len) {
            return TokenError.InvalidAccountData;
        }
        if (mint.is_initialized != 1) {
            return TokenError.UninitializedState;
        }

        //account.is_native = state.COption(u64).asNull();
        //account.amount = 0;
    }
}

fn transfer(program_id: *align(1) PublicKey, accounts: []Account, data: []const u8) TokenError!void {
    if (accounts.len < 3) {
        return TokenError.NotEnoughAccountKeys;
    }
    const ix_data: *align(1) const ix.AmountData = @ptrCast(data[1..]);
    const source_account = accounts[0];
    const destination_account = accounts[1];
    const authority_account = accounts[2];

    var source = try state.Account.fromBytes(source_account.data());
    var destination = try state.Account.fromBytes(destination_account.data());

    if (source.amount < ix_data.amount) {
        return TokenError.InsufficientFunds;
    }
    if (!source.mint.equals(destination.mint)) {
        return TokenError.MintMismatch;
    }

    //match source_account.delegate {
    //    COption::Some(ref delegate) if Self::cmp_pubkeys(authority_info.key, delegate) => {
    //        Self::validate_owner(
    //            program_id,
    //            delegate,
    //            authority_info,
    //            account_info_iter.as_slice(),
    //        )?;
    //        if source_account.delegated_amount < amount {
    //            return Err(TokenError::InsufficientFunds.into());
    //        }
    //        if !self_transfer {
    //            source_account.delegated_amount = source_account
    //                .delegated_amount
    //                .checked_sub(amount)
    //                .ok_or(TokenError::Overflow)?;
    //            if source_account.delegated_amount == 0 {
    //                source_account.delegate = COption::None;
    //            }
    //        }
    //    }
    try validateOwner(
        program_id,
        &source.owner,
        authority_account,
        accounts[3..],
    );

    const pre_amount = source.amount;
    source.amount -= ix_data.amount;
    destination.amount += ix_data.amount;

    if (source.isNative()) {
        source_account.lamports().* -= ix_data.amount;
        destination_account.lamports().* += ix_data.amount;
    }

    if (pre_amount == source.amount) {
        // self transfer or 0 token amount, check owners for safety
        if (!source_account.ownerId().equals(program_id.*)) {
            return TokenError.IllegalOwner;
        }
        if (!destination_account.ownerId().equals(program_id.*)) {
            return TokenError.IllegalOwner;
        }
    }
}

fn mintTo(program_id: *align(1) PublicKey, accounts: []Account, data: []const u8) TokenError!void {
    if (accounts.len < 3) {
        return TokenError.NotEnoughAccountKeys;
    }
    const ix_data: *align(1) const ix.AmountData = @ptrCast(data[1..]);
    const mint_account = accounts[0];
    const destination_account = accounts[1];
    const authority_account = accounts[2];

    var destination = try state.Account.fromBytes(destination_account.data());
    if (destination.isNative()) {
        return TokenError.NativeNotSupported;
    }
    if (!mint_account.id().equals(destination.mint)) {
        return TokenError.MintMismatch;
    }

    var mint = try state.Mint.fromBytes(mint_account.data());
    //if let Some(expected_decimals) = expected_decimals {
    //    if expected_decimals != mint.decimals {
    //        return Err(TokenError::MintDecimalsMismatch.into());
    //    }
    //}

    if (mint.mint_authority.is_some == 0) {
        return TokenError.FixedSupply;
    }

    try validateOwner(
        program_id,
        &mint.mint_authority.value,
        authority_account,
        accounts[3..],
    );

    if (ix_data.amount == 0) {
        if (!mint_account.ownerId().equals(program_id.*)) {
            return TokenError.IllegalOwner;
        }
        if (!destination_account.ownerId().equals(program_id.*)) {
            return TokenError.IllegalOwner;
        }
    }

    const supply = @addWithOverflow(mint.supply, ix_data.amount);
    if (supply[1] != 0) {
        return TokenError.Overflow;
    }
    mint.supply = supply[0];
    destination.amount += ix_data.amount;
}

fn burn(program_id: *align(1) PublicKey, accounts: []Account, data: []const u8) TokenError!void {
    if (accounts.len < 3) {
        return TokenError.NotEnoughAccountKeys;
    }
    const ix_data: *align(1) const ix.AmountData = @ptrCast(data[1..]);
    const source_account = accounts[0];
    const mint_account = accounts[1];
    const authority_account = accounts[2];

    var source = try state.Account.fromBytes(source_account.data());
    if (source.isNative()) {
        return TokenError.NativeNotSupported;
    }

    var mint = try state.Mint.fromBytes(mint_account.data());
    if (!mint_account.id().equals(source.mint)) {
        return TokenError.MintMismatch;
    }
    if (source.amount < ix_data.amount) {
        return TokenError.InsufficientFunds;
    }

    //if let Some(expected_decimals) = expected_decimals {
    //    if expected_decimals != mint.decimals {
    //        return Err(TokenError::MintDecimalsMismatch.into());
    //    }
    //}

    //if !source_account.is_owned_by_system_program_or_incinerator() {
    //match source_account.delegate {
    //COption::Some(ref delegate) if Self::cmp_pubkeys(authority_info.key, delegate) => {
    //Self::validate_owner(
    //program_id,
    //delegate,
    //authority_info,
    //account_info_iter.as_slice(),
    //)?;

    //if source_account.delegated_amount < amount {
    //return Err(TokenError::InsufficientFunds.into());
    //}
    //source_account.delegated_amount = source_account
    //.delegated_amount
    //.checked_sub(amount)
    //.ok_or(TokenError::Overflow)?;
    //if source_account.delegated_amount == 0 {
    //source_account.delegate = COption::None;
    //}
    //}
    //}
    //}
    try validateOwner(
        program_id,
        &source.owner,
        authority_account,
        accounts[3..],
    );

    source.amount -= ix_data.amount;
    mint.supply -= ix_data.amount;

    if (ix_data.amount == 0) {
        if (!mint_account.ownerId().equals(program_id.*)) {
            return TokenError.IllegalOwner;
        }
        if (!source_account.ownerId().equals(program_id.*)) {
            return TokenError.IllegalOwner;
        }
    }
}

fn closeAccount(program_id: *align(1) PublicKey, accounts: []Account) TokenError!void {
    if (accounts.len < 3) {
        return TokenError.NotEnoughAccountKeys;
    }
    const source_account = accounts[0];
    const destination_account = accounts[1];
    const authority_account = accounts[2];

    var source = try state.Account.fromBytes(source_account.data());
    if (!source.isNative() and source.amount != 0) {
        return TokenError.NonNativeHasBalance;
    }

    const authority = if (source.close_authority.is_some != 0)
        &source.close_authority.value
    else
        &source.owner;

    //if !source_account.is_owned_by_system_program_or_incinerator() {
    //Self::validate_owner(
    //program_id,
    //&authority,
    //authority_info,
    //account_info_iter.as_slice(),
    //)?;
    //} else if !solana_program::incinerator::check_id(destination_account_info.key) {
    //return Err(ProgramError::InvalidAccountData);
    //}

    try validateOwner(
        program_id,
        authority,
        authority_account,
        accounts[3..],
    );

    destination_account.lamports().* += source_account.lamports().*;
    source_account.lamports().* = 0;
    source_account.assign(system_program_id);
    source_account.reallocUnchecked(0);

    // if the destination has no more lamports, then this was a self-close,
    // which is not allowed
    if (destination_account.lamports().* == 0) {
        return TokenError.InvalidAccountData;
    }
}

fn processInstruction(program_id: *align(1) PublicKey, accounts: []Account, data: []const u8) TokenError!void {
    const instruction_type: *const ix.InstructionDiscriminant = @ptrCast(data);
    switch (instruction_type.*) {
        ix.InstructionDiscriminant.initialize_mint => {
            //sol.log("Instruction: InitializeMint");
            try initializeMint(accounts, data);
        },
        ix.InstructionDiscriminant.initialize_account => {
            //sol.log("Instruction: InitializeAccount");
            try initializeAccount(program_id, accounts);
        },
        ix.InstructionDiscriminant.initialize_multisig => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.transfer => {
            //sol.log("Instruction: Transfer");
            try transfer(program_id, accounts, data);
        },
        ix.InstructionDiscriminant.approve => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.revoke => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.set_authority => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.mint_to => {
            //sol.log("Instruction: MintTo");
            try mintTo(program_id, accounts, data);
        },
        ix.InstructionDiscriminant.burn => {
            //sol.log("Instruction: Burn");
            try burn(program_id, accounts, data);
        },
        ix.InstructionDiscriminant.close_account => {
            //sol.log("Instruction: CloseAccount");
            try closeAccount(program_id, accounts);
        },
        ix.InstructionDiscriminant.freeze_account => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.thaw_account => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.transfer_checked => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.approve_checked => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.mint_to_checked => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.burn_checked => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.initialize_account_2 => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.sync_native => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.initialize_account_3 => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.initialize_multisig_2 => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.initialize_mint_2 => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.get_account_data_size => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.initialize_immutable_owner => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.amount_to_ui_amount => {
            return TokenError.InvalidState;
        },
        ix.InstructionDiscriminant.ui_amount_to_amount => {
            return TokenError.InvalidState;
        },
    }
}

fn validateOwner(
    program_id: *align(1) const PublicKey,
    expected_owner: *align(1) const PublicKey,
    owner_account: Account,
    _: []Account,
) TokenError!void {
    if (!expected_owner.equals(owner_account.id())) {
        return TokenError.OwnerMismatch;
    }
    if (owner_account.dataLen() == state.Multisig.len and program_id.equals(owner_account.ownerId())) {
        //let multisig = Multisig::unpack(&owner_account_info.data.borrow())?;
        //let mut num_signers = 0;
        //let mut matched = [false; MAX_SIGNERS];
        //for signer in signers.iter() {
        //    for (position, key) in multisig.signers[0..multisig.n as usize].iter().enumerate() {
        //        if Self::cmp_pubkeys(key, signer.key) && !matched[position] {
        //            if !signer.is_signer {
        //                return Err(ProgramError::MissingRequiredSignature);
        //            }
        //            matched[position] = true;
        //            num_signers += 1;
        //        }
        //    }
        //}
        //if num_signers < multisig.m {
        return TokenError.MissingRequiredSignature;
        //}
    } else if (!owner_account.isSigner()) {
        return TokenError.MissingRequiredSignature;
    }
}

test {
    const std = @import("std");
    std.testing.refAllDecls(@This());
}

//! Program entrypoint

#![cfg(not(feature = "no-entrypoint"))]

use pinocchio::{
    lazy_entrypoint::{InstructionContext, MaybeAccount},
    program_error::ProgramError,
    ProgramResult,
};

// Since this is a single instruction program, we use the "lazy" variation
// of the entrypoint.
pinocchio::lazy_entrypoint!(process_instruction);

#[inline]
fn process_instruction(mut context: InstructionContext) -> ProgramResult {
    if context.remaining() != 2 {
        return Err(ProgramError::NotEnoughAccountKeys);
    }

    // This block is declared unsafe because:
    //
    // - We are using `next_account_unchecked`, which does not decrease the number of
    //   remaining accounts in the context. This is ok because we know that we have
    //   exactly two accounts.
    //
    // - We are using `assume_account` on the first account, which is ok because we
    //   know that we have at least one account.
    //
    // - We are using `borrow_mut_lamports_unchecked`, which is ok because we know
    //   that the lamports are not borrowed elsewhere and the accounts are different.
    unsafe {
        let source_info = context.next_account_unchecked().assume_account();

        // The second account is the destination account – this one could be duplicated.
        //
        // We only need to transfer lamports from the source to the destination when the
        // accounts are different, so we can safely ignore the case when the account is
        // duplicated.
        if let MaybeAccount::Account(destination_info) = context.next_account_unchecked() {
            let (instruction_data, _) = context.instruction_data_unchecked();
            let transfer_amount = u64::from_le_bytes(instruction_data.try_into().unwrap());
            // withdraw five lamports
            *source_info.borrow_mut_lamports_unchecked() -= transfer_amount;
            // deposit five lamports
            *destination_info.borrow_mut_lamports_unchecked() += transfer_amount;
        }
    }

    Ok(())
}

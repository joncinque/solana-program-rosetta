const log = @import("solana_program_sdk").log.log;

pub const TokenError = error{
    NotRentExempt,
    InsufficientFunds,
    InvalidMint,
    MintMismatch,
    OwnerMismatch,
    FixedSupply,
    AlreadyInUse,
    InvalidNumberOfProvidedSigners,
    InvalidNumberOfRequiredSigners,
    UninitializedState,
    NativeNotSupported,
    NonNativeHasBalance,
    InvalidInstruction,
    InvalidState,
    Overflow,
    AuthorityTypeNotSupported,
    MintCannotFreeze,
    AccountFrozen,
    MintDecimalsMismatch,
    NonNativeNotSupported,
    // generic program errors
    InvalidArgument,
    InvalidInstructionData,
    InvalidAccountData,
    AccountDataTooSmall,
    //InsufficientFunds,
    IncorrectProgramId,
    MissingRequiredSignature,
    AccountAlreadyInitialized,
    UninitializedAccount,
    NotEnoughAccountKeys,
    AccountBorrowFailed,
    MaxSeedLengthExceeded,
    InvalidSeeds,
    BorshIoError,
    AccountNotRentExempt,
    UnsupportedSysvar,
    IllegalOwner,
    MaxAccountsDataAllocationsExceeded,
    InvalidRealloc,
    MaxInstructionTraceLengthExceeded,
    BuiltinProgramsMustConsumeComputeUnits,
    InvalidAccountOwner,
    ArithmeticOverflow,
    Immutable,
    IncorrectAuthority,
};

pub fn logError(e: TokenError) void {
    switch (e) {
        TokenError.NotRentExempt => {
            log("Error: Lamport balance below rent-exempt threshold");
        },
        TokenError.InsufficientFunds => {
            log("Error: insufficient funds");
        },
        TokenError.InvalidMint => {
            log("Error: Invalid Mint");
        },
        TokenError.MintMismatch => {
            log("Error: Account not associated with this Mint");
        },
        TokenError.OwnerMismatch => {
            log("Error: owner does not match");
        },
        TokenError.FixedSupply => {
            log("Error: the total supply of this token is fixed");
        },
        TokenError.AlreadyInUse => {
            log("Error: account or token already in use");
        },
        TokenError.InvalidNumberOfProvidedSigners => {
            log("Error: Invalid number of provided signers");
        },
        TokenError.InvalidNumberOfRequiredSigners => {
            log("Error: Invalid number of required signers");
        },
        TokenError.UninitializedState => {
            log("Error: State is uninitialized");
        },
        TokenError.NativeNotSupported => {
            log("Error: Instruction does not support native tokens");
        },
        TokenError.NonNativeHasBalance => {
            log("Error: Non-native account can only be closed if its balance is zero");
        },
        TokenError.InvalidInstruction => {
            log("Error: Invalid instruction");
        },
        TokenError.InvalidState => {
            log("Error: Invalid account state for operation");
        },
        TokenError.Overflow => {
            log("Error: Operation overflowed");
        },
        TokenError.AuthorityTypeNotSupported => {
            log("Error: Account does not support specified authority type");
        },
        TokenError.MintCannotFreeze => {
            log("Error: This token mint cannot freeze accounts");
        },
        TokenError.AccountFrozen => {
            log("Error: Account is frozen");
        },
        TokenError.MintDecimalsMismatch => {
            log("Error: decimals different from the Mint decimals");
        },
        TokenError.NonNativeNotSupported => {
            log("Error: Instruction does not support non-native tokens");
        },
        TokenError.InvalidArgument => {},
        TokenError.InvalidInstructionData => {},
        TokenError.InvalidAccountData => {},
        TokenError.AccountDataTooSmall => {},
        TokenError.InsufficientFunds => {},
        TokenError.IncorrectProgramId => {},
        TokenError.MissingRequiredSignature => {},
        TokenError.AccountAlreadyInitialized => {},
        TokenError.UninitializedAccount => {},
        TokenError.NotEnoughAccountKeys => {},
        TokenError.AccountBorrowFailed => {},
        TokenError.MaxSeedLengthExceeded => {},
        TokenError.InvalidSeeds => {},
        TokenError.BorshIoError => {},
        TokenError.AccountNotRentExempt => {},
        TokenError.UnsupportedSysvar => {},
        TokenError.IllegalOwner => {},
        TokenError.MaxAccountsDataAllocationsExceeded => {},
        TokenError.InvalidRealloc => {},
        TokenError.MaxInstructionTraceLengthExceeded => {},
        TokenError.BuiltinProgramsMustConsumeComputeUnits => {},
        TokenError.InvalidAccountOwner => {},
        TokenError.ArithmeticOverflow => {},
        TokenError.Immutable => {},
        TokenError.IncorrectAuthority => {},
    }
}

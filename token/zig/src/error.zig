const sol = @import("solana-program-sdk");

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
            sol.log("Error: Lamport balance below rent-exempt threshold");
        },
        TokenError.InsufficientFunds => {
            sol.log("Error: insufficient funds");
        },
        TokenError.InvalidMint => {
            sol.log("Error: Invalid Mint");
        },
        TokenError.MintMismatch => {
            sol.log("Error: Account not associated with this Mint");
        },
        TokenError.OwnerMismatch => {
            sol.log("Error: owner does not match");
        },
        TokenError.FixedSupply => {
            sol.log("Error: the total supply of this token is fixed");
        },
        TokenError.AlreadyInUse => {
            sol.log("Error: account or token already in use");
        },
        TokenError.InvalidNumberOfProvidedSigners => {
            sol.log("Error: Invalid number of provided signers");
        },
        TokenError.InvalidNumberOfRequiredSigners => {
            sol.log("Error: Invalid number of required signers");
        },
        TokenError.UninitializedState => {
            sol.log("Error: State is uninitialized");
        },
        TokenError.NativeNotSupported => {
            sol.log("Error: Instruction does not support native tokens");
        },
        TokenError.NonNativeHasBalance => {
            sol.log("Error: Non-native account can only be closed if its balance is zero");
        },
        TokenError.InvalidInstruction => {
            sol.log("Error: Invalid instruction");
        },
        TokenError.InvalidState => {
            sol.log("Error: Invalid account state for operation");
        },
        TokenError.Overflow => {
            sol.log("Error: Operation overflowed");
        },
        TokenError.AuthorityTypeNotSupported => {
            sol.log("Error: Account does not support specified authority type");
        },
        TokenError.MintCannotFreeze => {
            sol.log("Error: This token mint cannot freeze accounts");
        },
        TokenError.AccountFrozen => {
            sol.log("Error: Account is frozen");
        },
        TokenError.MintDecimalsMismatch => {
            sol.log("Error: decimals different from the Mint decimals");
        },
        TokenError.NonNativeNotSupported => {
            sol.log("Error: Instruction does not support non-native tokens");
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

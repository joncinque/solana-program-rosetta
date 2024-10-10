#![allow(clippy::arithmetic_side_effects)]
//! Program instruction processor

use pinocchio::{
    account_info::AccountInfo, entrypoint::ProgramResult, program_error::ProgramError,
    pubkey::Pubkey,
};

/// Instruction processor
pub fn process_instruction(
    _program_id: &Pubkey,
    accounts: &[AccountInfo],
    _instruction_data: &[u8],
) -> ProgramResult {
    // As part of the program specification the first account is the source
    // account and the second is the destination account
    let [source_info, destination_info] = accounts else {
        return Err(ProgramError::NotEnoughAccountKeys);
    };

    // Withdraw five lamports from the source
    *source_info.try_borrow_mut_lamports()? -= 5;
    // Deposit five lamports into the destination
    *destination_info.try_borrow_mut_lamports()? += 5;

    Ok(())
}

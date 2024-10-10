//! Rust example demonstrating invoking another program
#![deny(missing_docs)]
#![forbid(unsafe_code)]

use pinocchio::{
    account_info::AccountInfo,
    entrypoint,
    entrypoint::ProgramResult,
    instruction::{Seed, Signer},
    program_error::ProgramError,
    pubkey::{create_program_address, Pubkey},
};
use pinocchio_system::instructions::Allocate;

pinocchio::entrypoint!(process_instruction);

/// Amount of bytes of account data to allocate
pub const SIZE: usize = 42;

/// Instruction processor
pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    // Account info to allocate abd for the program being invoked
    let [allocated_info, _system_program_info] = accounts else {
        return Err(ProgramError::NotEnoughAccountKeys);
    };

    let expected_allocated_key =
        create_program_address(&[b"You pass butter", &[instruction_data[0]]], program_id)?;
    if *allocated_info.key() != expected_allocated_key {
        // allocated key does not match the derived address
        return Err(ProgramError::InvalidArgument);
    }

    // Invoke the system program to allocate account data
    Allocate {
        account: allocated_info,
        space: SIZE as u64,
    }
    .invoke_signed(&[Signer::from(&[
        Seed::from(b"You pass butter"),
        Seed::from(&[instruction_data[0]]),
    ])])?;

    Ok(())
}

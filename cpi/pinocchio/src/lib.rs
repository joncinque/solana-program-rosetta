//! Rust example using pinocchio demonstrating invoking another program
#![deny(missing_docs)]

use pinocchio::{
    instruction::{Account, AccountMeta, Instruction},
    lazy_entrypoint::InstructionContext,
    program::invoke_signed_unchecked,
    program_error::ProgramError,
    pubkey::create_program_address,
    signer, ProgramResult,
};

// Since this is a single instruction program, we use the "lazy" variation
// of the entrypoint.
pinocchio::lazy_entrypoint!(process_instruction);

/// Amount of bytes of account data to allocate
pub const SIZE: usize = 42;

/// Instruction processor.
fn process_instruction(mut context: InstructionContext) -> ProgramResult {
    if context.remaining() != 2 {
        return Err(ProgramError::NotEnoughAccountKeys);
    }

    // Account info to allocate and for the program being invoked. We know that
    // we got 2 accounts, so it is ok use `next_account_unchecked` twice.
    let allocated_info = unsafe { context.next_account_unchecked().assume_account() };
    // just move the offset, we don't need the system program info
    let _system_program_info = unsafe { context.next_account_unchecked() };

    // Again, don't need to check that all accounts have been consumed, we know
    // we have exactly 2 accounts.
    let (instruction_data, program_id) = unsafe { context.instruction_data_unchecked() };

    let expected_allocated_key =
        create_program_address(&[b"You pass butter", &[instruction_data[0]]], program_id)?;
    if *allocated_info.key() != expected_allocated_key {
        // allocated key does not match the derived address
        return Err(ProgramError::InvalidArgument);
    }

    // Invoke the system program to allocate account data
    let mut data = [0; 12];
    data[0] = 8; // ix discriminator
    data[4..12].copy_from_slice(&SIZE.to_le_bytes());

    let instruction = Instruction {
        program_id: &pinocchio_system::ID,
        accounts: &[AccountMeta::writable_signer(allocated_info.key())],
        data: &data,
    };

    // Invoke the system program with the 'unchecked' function - this is ok since
    // we know the accounts are not borrowed elsewhere.
    unsafe {
        invoke_signed_unchecked(
            &instruction,
            &[Account::from(&allocated_info)],
            &[signer!(b"You pass butter", &[instruction_data[0]])],
        )
    };

    Ok(())
}

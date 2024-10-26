//! Program entrypoint

#![cfg(not(feature = "no-entrypoint"))]

use pinocchio::{lazy_entrypoint::InstructionContext, ProgramResult};

// Since this is a single instruction program, we use the "lazy" variation
// of the entrypoint.
pinocchio::lazy_entrypoint!(process_instruction);

#[inline]
unsafe fn process_instruction(mut context: InstructionContext) -> ProgramResult {
    // Account infos used in the transfer. Here we are optimizing for CU, so we
    // are not checking that the accounts are present ('unchecked' method has UB
    // if the account is missing).
    let source_info = context.next_account_unchecked().assume_account();
    let destination_info = context.next_account_unchecked().assume_account();

    // Transfer five lamports from the source to the destination using 'unchecked'
    // borrowing. This is safe since we know the lamports are not borrowed elsewhere.
    *source_info.borrow_mut_lamports_unchecked() -= 5; // withdraw five lamports
    *destination_info.borrow_mut_lamports_unchecked() += 5; // deposit five lamports

    Ok(())
}

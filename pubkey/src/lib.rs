//! A program demonstrating a comparison of pubkeys
#![deny(missing_docs)]
#![allow(clippy::arithmetic_side_effects)]

use solana_pubkey::Pubkey;

/// Entrypoint for the program
#[no_mangle]
pub extern "C" fn entrypoint(input: *mut u8) -> u64 {
    unsafe {
        let key: &Pubkey = &*(input.add(16) as *const Pubkey);
        let owner: &Pubkey = &*(input.add(16 + 32) as *const Pubkey);

        if *key == *owner {
            0
        } else {
            1
        }
    }
}
#[cfg(target_os = "solana")]
#[no_mangle]
fn custom_panic(_info: &core::panic::PanicInfo<'_>) {}
solana_program_entrypoint::custom_heap_default!();

use solana_msg::msg;

#[no_mangle]
pub extern "C" fn entrypoint(_: *mut u8) -> u64 {
    msg!("Hello world!");
    0
}
#[cfg(target_os = "solana")]
#[no_mangle]
fn custom_panic(_info: &core::panic::PanicInfo<'_>) {}
solana_program_entrypoint::custom_heap_default!();

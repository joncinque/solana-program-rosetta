use {
    solana_program::instruction::Instruction,
    solana_program_test::{tokio, ProgramTest},
    solana_sdk::{signature::Signer, transaction::Transaction},
};
mod program {
    solana_program::declare_id!("1og1111111111111111111111111111111111111111");
}
fn program_test() -> ProgramTest {
    ProgramTest::new("solana_program_rosetta_helloworld", program::id(), None)
}
#[tokio::test]
async fn call() {
    let pt = program_test();
    let mut context = pt.start_with_context().await;
    let blockhash = context.banks_client.get_latest_blockhash().await.unwrap();
    let transaction = Transaction::new_signed_with_payer(
        &[Instruction {
            program_id: program::id(),
            accounts: vec![],
            data: vec![],
        }],
        Some(&context.payer.pubkey()),
        &[&context.payer],
        blockhash,
    );
    context
        .banks_client
        .process_transaction(transaction)
        .await
        .unwrap();
}

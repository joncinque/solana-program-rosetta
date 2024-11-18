use {
    solana_instruction::{AccountMeta, Instruction},
    solana_program_test::*,
    solana_pubkey::Pubkey,
    solana_sdk::{account::Account, signature::Signer, transaction::Transaction},
};

const PROGRAM_ID: Pubkey = Pubkey::from_str_const("PubkeyComp111111111111111111111111111111111");
const TEST_KEY: Pubkey = Pubkey::from_str_const("PubkeyComp111111111111111111111111111111112");

#[tokio::test]
async fn correct_key() {
    let mut program_test = ProgramTest::new(
        option_env!("PROGRAM_NAME").unwrap_or("solana_program_rosetta_pubkey"),
        PROGRAM_ID,
        None,
    );
    program_test.add_account(
        TEST_KEY,
        Account {
            lamports: 100_000,
            data: vec![0],
            owner: TEST_KEY,
            ..Account::default()
        },
    );
    let (banks_client, payer, recent_blockhash) = program_test.start().await;

    let mut transaction = Transaction::new_with_payer(
        &[Instruction::new_with_bincode(
            PROGRAM_ID,
            &(),
            vec![AccountMeta::new_readonly(TEST_KEY, false)],
        )],
        Some(&payer.pubkey()),
    );
    transaction.sign(&[&payer], recent_blockhash);
    banks_client.process_transaction(transaction).await.unwrap();
}

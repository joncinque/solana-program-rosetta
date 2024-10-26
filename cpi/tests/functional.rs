use {
    solana_program::{
        instruction::{AccountMeta, Instruction},
        pubkey::Pubkey,
        rent::Rent,
        system_program,
    },
    solana_program_rosetta_cpi::SIZE,
    solana_program_test::*,
    solana_sdk::{account::Account, signature::Signer, transaction::Transaction},
    std::str::FromStr,
};

/// The name of the program to test when using the `solana_program` library.
const SOLANA_PROGRAM: &str = "solana_program_rosetta_cpi";

/// The name of the program to test when using the `pinocchio` library.
const PINOCCHIO_PROGRAM: &str = "pinocchio_rosetta_cpi";

#[tokio::test]
async fn test_cross_program_invocation() {
    let program_id = Pubkey::from_str("invoker111111111111111111111111111111111111").unwrap();
    let (allocated_pubkey, bump_seed) =
        Pubkey::find_program_address(&[b"You pass butter"], &program_id);

    let library = std::env::var("ROSETTA_LIBRARY").unwrap_or(String::from("solana_program"));
    let mut program_test = ProgramTest::new(
        match library.as_str() {
            "pinocchio" => PINOCCHIO_PROGRAM,
            _ => SOLANA_PROGRAM,
        },
        program_id,
        None,
    );

    program_test.add_account(
        allocated_pubkey,
        Account {
            lamports: Rent::default().minimum_balance(SIZE),
            ..Account::default()
        },
    );

    let (mut banks_client, payer, recent_blockhash) = program_test.start().await;

    let mut transaction = Transaction::new_with_payer(
        &[Instruction::new_with_bincode(
            program_id,
            &[bump_seed],
            vec![
                AccountMeta::new(allocated_pubkey, false),
                AccountMeta::new_readonly(system_program::id(), false),
            ],
        )],
        Some(&payer.pubkey()),
    );
    transaction.sign(&[&payer], recent_blockhash);
    banks_client.process_transaction(transaction).await.unwrap();

    // Associated account now exists
    let allocated_account = banks_client
        .get_account(allocated_pubkey)
        .await
        .expect("get_account")
        .expect("associated_account not none");
    assert_eq!(allocated_account.data.len(), SIZE);
}

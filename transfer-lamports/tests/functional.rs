use {
    solana_program::{
        instruction::{AccountMeta, Instruction},
        pubkey::Pubkey,
    },
    solana_program_test::*,
    solana_sdk::{account::Account, signature::Signer, transaction::Transaction},
    std::str::FromStr,
};

/// The name of the program to test when using the `solana_program` library.
const SOLANA_PROGRAM: &str = "solana_program_rosetta_transfer_lamports";

/// The name of the program to test when using the `pinocchio` library.
const PINOCCHIO_PROGRAM: &str = "pinocchio_rosetta_transfer_lamports";

#[tokio::test]
async fn test_lamport_transfer() {
    let program_id = Pubkey::from_str("TransferLamports111111111111111111111111111").unwrap();
    let source_pubkey = Pubkey::new_unique();
    let destination_pubkey = Pubkey::new_unique();

    let library = std::env::var("ROSETTA_LIBRARY").unwrap_or(String::from("solana_program"));
    let mut program_test = ProgramTest::new(
        match library.as_str() {
            "pinocchio" => PINOCCHIO_PROGRAM,
            _ => SOLANA_PROGRAM,
        },
        program_id,
        None,
    );

    let source_lamports = 5;
    let destination_lamports = 890_875;
    program_test.add_account(
        source_pubkey,
        Account {
            lamports: source_lamports,
            data: vec![0],
            owner: program_id, // Can only withdraw lamports from accounts owned by the program
            ..Account::default()
        },
    );
    program_test.add_account(
        destination_pubkey,
        Account {
            lamports: destination_lamports,
            ..Account::default()
        },
    );
    let (mut banks_client, payer, recent_blockhash) = program_test.start().await;

    let mut transaction = Transaction::new_with_payer(
        &[Instruction::new_with_bincode(
            program_id,
            &(),
            vec![
                AccountMeta::new(source_pubkey, false),
                AccountMeta::new(destination_pubkey, false),
            ],
        )],
        Some(&payer.pubkey()),
    );
    transaction.sign(&[&payer], recent_blockhash);
    banks_client.process_transaction(transaction).await.unwrap();
    let source = banks_client.get_account(source_pubkey).await.unwrap();
    assert_eq!(source, None);
    let destination = banks_client
        .get_account(destination_pubkey)
        .await
        .unwrap()
        .unwrap();
    assert_eq!(destination.lamports, destination_lamports + source_lamports);
}

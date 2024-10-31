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

#[tokio::test]
async fn test_cross_program_invocation() {
    let program_id = Pubkey::from_str("invoker111111111111111111111111111111111111").unwrap();
    let (allocated_pubkey, bump_seed) =
        Pubkey::find_program_address(&[b"You pass butter"], &program_id);

    let mut program_test = ProgramTest::new(
        option_env!("PROGRAM_NAME").unwrap_or("solana_program_rosetta_cpi"),
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

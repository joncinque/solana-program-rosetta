/**
 * @brief C-based Transfer Lamports BPF program
 */
#include <solana_sdk.h>

extern uint64_t entrypoint(const uint8_t *input) {
  SolAccountInfo accounts[2];
  SolParameters params = (SolParameters){.ka = accounts};

  if (!sol_deserialize(input, &params, SOL_ARRAY_SIZE(accounts))) {
    return ERROR_INVALID_ARGUMENT;
  }

  uint64_t transfer_amount = *(uint64_t *) params.data;
  SolAccountInfo source_account = params.ka[0];
  SolAccountInfo destination_account = params.ka[1];
  *source_account.lamports -= transfer_amount;
  *destination_account.lamports += transfer_amount;

  return 0;
}

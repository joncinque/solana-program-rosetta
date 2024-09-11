/**
 * @brief C-based Helloworld BPF program
 */
#include <solana_sdk.h>

extern uint64_t entrypoint(const uint8_t *input) {
  SolAccountInfo accounts[2];
  SolParameters params = (SolParameters){.ka = accounts};

  if (!sol_deserialize(input, &params, SOL_ARRAY_SIZE(accounts))) {
    return ERROR_INVALID_ARGUMENT;
  }

  SolAccountInfo source_account = params.ka[0];
  SolAccountInfo destination_account = params.ka[1];
  *source_account.lamports -= 5;
  *destination_account.lamports += 5;

  return 0;
}

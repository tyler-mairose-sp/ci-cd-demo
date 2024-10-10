@test "Verify DeriveFirstInitialLastNameInUpper Transform" {
    RESULT="$(sail transform preview --profile 8b9960eebbdd43029393edd9dcf25976 --identity 87d230a88b3346348d20bcc43b759965 --file transform_files/DeriveFirstInitialLastNameInUpper.json -r)"
    [ "$RESULT" = "ANICHOLS" ]
}

@test "Verify DetermineLicense Transform" {
    RESULT="$(sail transform preview --profile 8b9960eebbdd43029393edd9dcf25976 --identity 87d230a88b3346348d20bcc43b759965 --file transform_files/DetermineLicense.json -r)"
    [ "$RESULT" = "licensed" ]
}

@test "Verify DetermineLifecycleState Transform" {
    RESULT="$(sail transform preview --profile 8b9960eebbdd43029393edd9dcf25976 --identity ef661602fccb40b9848fea8cfbe78f20 --file transform_files/DetermineLifecycleState.json -r)"
    [ "$RESULT" = "prehire" ]
}

@test "Verify FormatGCPEmail Transform" {
    RESULT="$(sail transform preview --profile 8b9960eebbdd43029393edd9dcf25976 --identity 1d2d747380634a38a48f079422833ed6 --file transform_files/FormatGCPEmail.json -r)"
    [ "$RESULT" = "adam.kennedy@se-gcp.sailpointtechnologies.com" ]
}

context("Estimate primer complementarity using Primer3")

# test checkPrimers() ------------------------------------------------------------------------------

# get chr11 example primers
data("chr11_primers")
primers <- pickPrimers(chr11_primers, n = 1, by = "off_targets")

test_that("checkPrimers() aborts correctly if less than 2 primers are provided", {
  expect_error(checkPrimers(primers[[1]]),  "At least 2 TAP-seq primers needed!")
})

# test check_primers_io() --------------------------------------------------------------------------

# example primer pairs
pair1 <- c(AKIP1.primer_left_2  = "ATCACAGAGGCGAGTCGAAG",
           ARFIP2.primer_left_0 = "CAGGGTGTGGGAGATTGGAC")

pair2 <- c(AKIP1.primer_left_2 = "ATCACAGAGGCGAGTCGAAG",
           BET1L.primer_left_2 = "CCTCCCCGCCTCTCTTATCT")

pair3 <- c(AKIP1.primer_left_2 = "ATCACAGAGGCGAGTCGAAG",
           GENE1.primer_left_0 = "CTTCGACTCGCCTCTGTGAT")

# expected output io records
expect_pair1 <- c("SEQUENCE_ID=AKIP1.primer_left_2-ARFIP2.primer_left_0",
                  "SEQUENCE_PRIMER=ATCACAGAGGCGAGTCGAAG",
                  "SEQUENCE_PRIMER_REVCOMP=CAGGGTGTGGGAGATTGGAC",
                  "PRIMER_TASK=check_primers",
                  "PRIMER_EXPLAIN_FLAG=1",
                  "=")

expect_pair2 <- c("SEQUENCE_ID=AKIP1.primer_left_2-BET1L.primer_left_2",
                  "SEQUENCE_PRIMER=ATCACAGAGGCGAGTCGAAG",
                  "SEQUENCE_PRIMER_REVCOMP=CCTCCCCGCCTCTCTTATCT",
                  "PRIMER_TASK=check_primers",
                  "PRIMER_EXPLAIN_FLAG=1",
                  "PRIMER_OPT_TM=63",
                  "=")

test_that("check_primers_io() returns correct output", {
  out1 <- check_primers_io(pair1)
  out2 <- check_primers_io(pair2, primer_opt_tm = 63)
  expect_true(is(out1, "character"))
  expect_identical(out1, expect_pair1)
  expect_identical(out2, expect_pair2)
})

test_that("check_primers_io() aborts if one sequence is the reverse complement of the other", {
  expect_error(check_primers_io(pair3), "Primers are reverse complements in pair:")
})

# test primer_pairs_io() ---------------------------------------------------------------------------

expect_out1 <- c(expect_pair1, expect_pair2[-6])
expect_out2 <- c(expect_pair1[1:5], "PRIMER_OPT_TM=63", "=", expect_pair2)

test_that("primer_pairs_io() returns correct output", {
  out1 <- primer_pairs_io(list(pair1, pair2))
  out2 <- primer_pairs_io(list(pair1, pair2), primer_opt_tm = 63)
  expect_true(is(out1, "character"))
  expect_identical(out1, expect_out1)
  expect_identical(out2, expect_out2)
})

test_that("primer_pairs_io() correctly handles reverse complement primers", {
  expect_message(out <- primer_pairs_io(list(pair1, pair2, pair3)),
                 "Primers are reverse complements in pair")
  expect_true(is(out, "character"))
  expect_identical(out, expect_out1)
})

# test process_output_record() ---------------------------------------------------------------------

# primer3 output example
primer3_output <- c(sequence_id = "AKIP1.primer_left_4-ARFIP2.primer_left_2",
                    sequence_primer = "CAGAGGCGAGTCGAAGCTGC",
                    sequence_primer_revcomp = "CTGGGGCCTGACACCAGTTT",
                    primer_task = "check_primers",
                    primer_explain_flag = "1",
                    primer_opt_tm = "63",
                    primer_min_tm = "59",
                    primer_max_tm = "66",
                    primer_left_explain = "considered 1, ok 1",
                    primer_right_explain = "considered 1, ok 1",
                    primer_pair_explain = "considered 1, ok 1",
                    primer_left_num_returned = "1",
                    primer_right_num_returned = "1",
                    primer_internal_num_returned = "0",
                    primer_pair_num_returned = "1",
                    primer_pair_0_penalty = "1.115793",
                    primer_left_0_penalty = "0.473386",
                    primer_right_0_penalty = "0.642407",
                    primer_left_0_sequence = "CAGAGGCGAGTCGAAGCTGC",
                    primer_right_0_sequence = "CTGGGGCCTGACACCAGTTT",
                    primer_left_0 = "0,20",
                    primer_right_0 = "199,20",
                    primer_left_0_tm = "63.473",
                    primer_right_0_tm = "62.358",
                    primer_left_0_gc_percent = "65.000",
                    primer_right_0_gc_percent = "60.000",
                    primer_left_0_self_any_th = "18.61",
                    primer_right_0_self_any_th = "14.98",
                    primer_left_0_self_end_th = "0.00",
                    primer_right_0_self_end_th = "0.00",
                    primer_left_0_hairpin_th = "0.00",
                    primer_right_0_hairpin_th = "45.21",
                    primer_left_0_end_stability = "5.2500",
                    primer_right_0_end_stability = "2.6600",
                    primer_pair_0_compl_any_th = "0.00",
                    primer_pair_0_compl_end_th = "0.00",
                    primer_pair_0_product_size = "200")

# expected output
expect_out <- data.frame(primer1 = "AKIP1.primer_left_4",
                         primer2 = "ARFIP2.primer_left_2",
                         primer1_seq = "CAGAGGCGAGTCGAAGCTGC",
                         primer2_seq = "CTGGGGCCTGACACCAGTTT",
                         primer1_penalty = 0.473386,
                         primer2_penalty = 0.642407,
                         primer_pair_penalty = 1.115793,
                         primer_pair_compl_any_th = 0,
                         primer_pair_compl_end_th = 0,
                         stringsAsFactors = FALSE)

test_that("process_output_record() returns correct output", {
  out <- process_output_record(primer3_output)
  expect_true(is(out, "data.frame"))
  expect_identical(out, expect_out)
})

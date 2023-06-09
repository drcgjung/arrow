# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

skip_if(on_old_windows())

library(dplyr, warn.conflicts = FALSE)

tbl <- example_data
tbl$some_grouping <- rep(c(1, 2), 5)

test_that("distinct()", {
  compare_dplyr_binding(
    .input %>%
      distinct(some_grouping, lgl) %>%
      collect() %>%
      arrange(some_grouping, lgl),
    tbl
  )
})

test_that("distinct() works without any variables", {
  compare_dplyr_binding(
    .input %>%
      distinct() %>%
      arrange(int) %>%
      collect(),
    tbl
  )

  compare_dplyr_binding(
    .input %>%
      group_by(x = int + 1) %>%
      distinct() %>%
      # Even though we have group_by(x), all cols (including int) are kept
      arrange(int) %>%
      collect(),
    tbl
  )
})

test_that("distinct() can retain groups", {
  compare_dplyr_binding(
    .input %>%
      group_by(some_grouping, int) %>%
      distinct(lgl) %>%
      collect() %>%
      arrange(lgl, int),
    tbl
  )

  # With expressions here
  compare_dplyr_binding(
    .input %>%
      group_by(y = some_grouping, int) %>%
      distinct(x = lgl) %>%
      collect() %>%
      arrange(int),
    tbl
  )
})

test_that("distinct() can contain expressions", {
  compare_dplyr_binding(
    .input %>%
      distinct(lgl, x = some_grouping + 1) %>%
      collect() %>%
      arrange(lgl, x),
    tbl
  )

  compare_dplyr_binding(
    .input %>%
      group_by(lgl, int) %>%
      distinct(x = some_grouping + 1) %>%
      collect() %>%
      arrange(int),
    tbl
  )
})

test_that("distinct() can return all columns", {
  skip("ARROW-13993 - need this to return correct rows from other cols")
  compare_dplyr_binding(
    .input %>%
      distinct(lgl, .keep_all = TRUE) %>%
      collect() %>%
      arrange(int),
    tbl
  )
})

#include <gtest/gtest.h>
#include "../math_operations.h"

// Test suite for the add function
TEST(AdditionTests, BasicAddition) {
EXPECT_EQ(add(2, 3), 5);
EXPECT_EQ(add(-1, 1), 0);
EXPECT_EQ(add(0, 0), 0);
EXPECT_EQ(add(-5, -3), -8);
}
//
// Created by Maryana on 13.10.2025.
//

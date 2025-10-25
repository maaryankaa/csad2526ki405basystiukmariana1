cmake_minimum_required(VERSION 3.23)
project(csad2526ki405basystiukmariana1)

set(CMAKE_CXX_STANDARD 14)

# Основний виконуваний файл
add_executable(csad2526ki405basystiukmariana1
        main.cpp
        math_operations.cpp)

# Підключення Google Test
include(FetchContent)
FetchContent_Declare(
        googletest
        URL https://github.com/google/googletest/archive/refs/heads/main.zip
)
# Забезпечуємо збірку Google Test
FetchContent_MakeAvailable(googletest)

enable_testing()  # Вмикаємо підтримку тестів

# Створюємо виконуваний файл для тестів
add_executable(unit_tests
        tests/unit_tests.cpp
        math_operations.cpp)

# Лінкуємо тестовий виконуваний файл з бібліотекою gtest
target_link_libraries(unit_tests gtest gtest_main)

# Реєструємо тести
add_test(NAME BasicAdditionTest COMMAND unit_tests)

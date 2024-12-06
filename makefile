# Определение путей к директориям с проектом
SRC_DIR := ./src
OUT_DIR := ./out
INC_DIR := ./inc
UNIT_DIR := ./unit_tests


# Задаю имена будущим исполняемым файлам
EXE_NAME := app.exe
EXE_UNIT := unit_tests.exe

# Настройки компиляции
CC := gcc # Выбор компилятора

# gnu99 Для time.h
CFLAGS := -std=c99 -I $(INC_DIR)/ -Werror -Wall -pedantic -Wfloat-conversion -Wfloat-equal -Wvla -Wextra # Флаги компиляции по умоланию
LDFLAGS := -lm # Флаг линковки по умолчанию

# Исходные файлы и объектные файлы
src_files := $(wildcard $(SRC_DIR)/*.c)
app_objs := $(patsubst $(SRC_DIR)/%.c, $(OUT_DIR)/%.o, $(filter-out $(SRC_DIR)/main.c, $(src_files)))

# Файлы с тестами и объектные файлы тестов
test_srs_files := $(wildcard $(UNIT_DIR)/*.c)
test_objs := $(patsubst $(UNIT_DIR)/%.c, $(OUT_DIR)/%.o, $(test_srs_files))

# Файл с main() для тестов
main := $(OUT_DIR)/main.o


$(EXE_NAME): $(app_objs) $(main)
	$(CC) $(app_objs) $(main) $(LDFLAGS) -o $@ 

# Сборка тестов
$(EXE_UNIT): $(test_objs) $(app_objs)
	$(CC) $(test_objs) $(app_objs) -o $@ -lcheck $(LDFLAGS)

# Компиляция основных файлов
$(OUT_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS)  -c $< -o  $@

# Компиляция тестов файлов
$(OUT_DIR)/%.o: $(UNIT_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

# Компиляция check_main.c покрытием
$(CHECK_MAIN): $(UNIT_DIR)/check_main.c
	$(CC) $(CFLAGS) -c $< -o $@ 

# Компиляция main.c для основного приложения
$(SOURSE_MAIN): $(SRC_DIR)/main.c
	$(CC) $(CFLAGS) -c $< -o $@ 

# Обозначение фиктивных целей
.PHONY : clean release debug asan msan ubsan coverage func unit myunit macunit

# Цель очистки
clean:
	$(RM) *.exe $(OUT_DIR)/*.o *.o *.out $(OUT_DIR)/*.gcno $(OUT_DIR)/*.gcda $(OUT_DIR)/*.d *.gcov

# Цель build release
release: CFLAGS += -DNDEBUG -g0
release: $(EXE_NAME)

# Цель build debug
debug: CFLAGS += -g3 -O0
debug: $(EXE_NAME)

# Цель build asan
asan: CC = clang
asan: CFLAGS += -g -fno-omit-frame-pointer -fsanitize=address
asan: LDFLAGS := -fsanitize=address
asan: $(EXE_NAME)

# Цель build msan
msan: CC = clang
msan: CFLAGS += -g -fPIE -fno-omit-frame-pointer -fsanitize=memory
msan: LDFLAGS := -fsanitize=memory -pie
msan: $(EXE_NAME)

# Цель build ubsan
ubsan: CC = clang
ubsan: CFLAGS += -fno-omit-frame-pointer -fsanitize=undefined -g
ubsan: LDFLAGS := -fsanitize=undefined
ubsan: $(EXE_NAME)

# Цель build coverage
coverage: CC = gcc
coverage: CFLAGS += -g --coverage -O0
coverage: LDFLAGS += --coverage
coverage: $(EXE_NAME)

func : $(EXE_NAME)
	./func_tests/scripts/func_tests.sh


unit: unit_tests.exe
	./unit_tests.exe

myunit: LDFLAGS += -lrt -lsubunit
myunit: CFLAGS += -g
myunit: unit_tests.exe
	./unit_tests.exe

macunit: LDFLAGS += -L/opt/homebrew/Cellar/check/0.15.2/lib
macunit: CFLAGS += -Wno-gnu-zero-variadic-macro-arguments -I/opt/homebrew/Cellar/check/0.15.2/include
macunit: unit_tests.exe
	./unit_tests.exe

dockerunit: LDFLAGS += -lcheck_pic -lrt -lsubunit 
dockerunit: CFLAGS += -pthread
dockerunit: unit_tests.exe
	./unit_tests.exe

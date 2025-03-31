CC = gcc
CFLAGS = -Wall -O2
TARGET = euclidean_distance transform
SRCS = euclidean_distance.c transform.c
OBJS = $(SRCS:.c=.o)

# Default target
all: $(TARGET)

# Build target
transform: transform.o
	$(CC) $(CFLAGS) -o transform transform.o

euclidean_distance: euclidean_distance.o
	$(CC) $(CFLAGS) -o euclidean_distance euclidean_distance.o

# Clean up
clean:
	rm -f $(TARGET) $(OBJS)


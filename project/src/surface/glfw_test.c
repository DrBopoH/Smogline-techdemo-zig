#include <GLFW/glfw3.h>
#include <stdio.h>

int main() {
	if (!glfwInit()) {
		printf("glfwInit failed\n");
		return 1;
	}
	printf("GLFW init OK\n");
	glfwTerminate();
	return 0;
}
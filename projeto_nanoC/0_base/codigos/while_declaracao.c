
int main(){
    int a,b;
	a = 0;
    b = 1;
	while (b <= 10) {
		int j;
		j = a + b;
	    a = j;
		b = b + 1;
	}
    return a;
}


int main(){
    int a,b;
	a = 0;
    b = 1;
	while (b <= 10) {
		int j;
		j = 0;
		while(j < 10){
			int x;
			x = a + b;
		    a = x;
			j = j + 1;
		}
		b = b + 1;
	}
    return a;
}

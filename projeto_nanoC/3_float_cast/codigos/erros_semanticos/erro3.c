int y,z;

int plus(int x, int y){
	return x + y;
}

void one(){
    int a;
	a=1;
}

// passando um tipo void quando se espera um int
int main(){
    int a,b;
    y = 5;
    z = 10;
    b = y + z;
    a = plus(b, one());
    return a;
}

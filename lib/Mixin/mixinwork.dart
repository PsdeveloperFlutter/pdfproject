mixin work{
  void onwork(String message ){
    print(message);
  }
}
mixin maybe{
void names(){
  print("Priyanshu satija");

}
}
class passenger with work , maybe{
  final String name;
  final bool ONwork;
  passenger({
    required this.name,
    required this.ONwork
});
  void displayinfo(){
    onwork("User name $name and they are on $ONwork");
  }
}

void main(){
  passenger value=passenger(name: "Priyanshu satija", ONwork: true);
  value.displayinfo();
  value.names();
}
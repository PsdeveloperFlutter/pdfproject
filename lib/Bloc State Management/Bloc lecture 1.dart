import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(MaterialApp(home: SimpleStateful(),));
}
class SimpleStateful extends StatefulWidget {
  @override
  _SimpleStatefulState createState() => _SimpleStatefulState();
}

class _SimpleStatefulState extends State<SimpleStateful> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child:Icon(Icons.add),
        onPressed:(){
          Person person=Person(name:'Priyanshu',age:22);
          Person person1=Person(name:"Priyanshu",age:22);
          print(person==person1);
          print(person1.hashCode);
          print(person.hashCode);
        }
      ),

    );
  }
}

class Person extends Equatable{
  final String name;
  final int age;
  const Person({required this.name , required this.age });

  @override
  // TODO: implement props
  List<Object?> get props => [name,age];

  //equatable package

}

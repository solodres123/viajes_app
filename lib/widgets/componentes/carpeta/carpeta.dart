import 'dart:math';
import 'package:flutter/material.dart';

class Carpeta extends StatelessWidget {

  const Carpeta({super.key});

  @override
  Widget build(BuildContext context) {

    final random = Random();
    const List<Color> pastelColors = [
      Color.fromARGB(255, 189, 229, 163),
      Color.fromARGB(255, 255, 183, 178),
      Color.fromARGB(255, 255, 231, 174),
      Color.fromARGB(255, 250, 213, 238),
      Color.fromARGB(255, 213, 220, 249)
      
    ];

    Color getRandomColor() {
      return pastelColors[random.nextInt(pastelColors.length)];
    }


    Color color = getRandomColor();
    Color getIconColor(Color backgroundColor) {
      final hslColor = HSLColor.fromColor(backgroundColor);
      final saturation = hslColor.saturation;
      final lightness = hslColor.lightness;
      final targetLightness = lightness > 0.5 ? lightness * 0.6 : lightness * 1.4;
      final targetSaturation = saturation > 0.5 ? saturation * 0.6 : saturation * 1.4;
      final iconHslColor = HSLColor.fromAHSL(1, hslColor.hue, targetSaturation, targetLightness);
      final iconColor = iconHslColor.toColor();
      return iconColor;
    }
    
    int size = ((min(MediaQuery.of(context).size.width.floor(),
                     MediaQuery.of(context).size.height.floor()
                     ))/3).floor();

    final maxWidth = size.toDouble()-10;
    final maxHeight = (size /0.724).toDouble()-10;
 
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAlias,
          elevation: 8,
          shadowColor: Colors.black,
          child:
           Stack(
             children:[ 
              

              Column(
                children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: maxHeight*0.06),
                  child: Container(
                    decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.all(Radius.circular(50))),
                    height: maxWidth*0.6,
                    width: maxWidth*0.6,
                    child: Icon(
                      Icons.bed,
                      color: getIconColor(color),
                      size: 40,
                    ),
                  ),
                ),
           
                const Center(
                  child: Text("Habitaciones",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,),
                ),
           
                 const Center(
                  child: Text(
                    "6 dormitorios \n 9 camas",
                      style: TextStyle(
                          color: Colors.black45,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,),
                ),
              ]
              ),

                     Container(
                  height: maxHeight,
                  width: maxWidth,
                  color: const Color.fromARGB(255, 214, 152, 6),    
                ),
                
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 207, 207, 207),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(15))
                      ),
                    height: maxHeight*0.95,
                    width: maxWidth,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 208, 99),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15))),
                    height: maxHeight,
                    width: maxWidth*0.5,
                    child: const Center(
                        child: Text("Editar",
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 20,
                                fontWeight: FontWeight.bold))),
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color.fromARGB(255, 255, 208, 99),Color.fromARGB(255, 255, 255, 255)],
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      stops: [0.36,0.36],
                       ),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15))),
                    height: maxHeight*0.92,
                    width: maxWidth,
                    child: const Center(
                        child: Text("Editar",
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 20,
                                fontWeight: FontWeight.bold))),
                  ),
                )
                
                

                     ],
                
           )
        )
      )
    ); 
  }
}

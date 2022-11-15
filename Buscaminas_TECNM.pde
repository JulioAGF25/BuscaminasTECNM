// Buscaminas en processing 

// Ancho y alto del tablero
int ancho = 30;
int alto = 16;

 // Tamaño del tablero de juego 
int[][] tablero = new int[ancho][alto];

// Arreglo de porcentaje de probabilidad de estar en una mina
float[][] porcentajeTablero = new float[ancho][alto];

// Esto representa el porcentaje de probabilidad de que una ficha determinada salga como mina.
// En un mapa experto normal de 30x16 con 99 minas, la probabilidad de que cualquier celda sea una mina es del 20,625 %.
// Ajuste esta variable para ajustar la dificultad. 0.05 es bastante fácil. 0.1 es aproximadamente medio. 0.2 es difícil.
float densidadDeMinas = 0.05; // 0.20625;

  // Busca el numero de cuantas minas quedan en el juego
int minasRestantes;

// Se asegura que en la primera jugada no haya ninguna mina 
boolean primerJugada;

// Esta variable se hace verdadera (true), cuando se gana el juego
boolean victoria;

int lcx, lcy;

void setup()
{
    size(600,360);
    ellipseMode(CENTER);
    rectMode(CORNER);
    textSize(14);
    primerJugada = true;
    minasRestantes = 0;
    lcx = -1;
    lcy = -1;
    victoria = false;
    //Inicia el juego con las minas aleatorias
    for (int i = 0; i < ancho; i++)
    {
        for (int j = 0; j < alto; j++)
        {
            if (random(0,1) < densidadDeMinas)
            {
                tablero[i][j] = 9;
                minasRestantes++;
            }
            else
            {
                tablero[i][j] = -1;
            }
        }
    }
}

void draw()
{
    background(60);
    
    //Muestra cuantas minas quedan en el juego
    fill(#FFFFFF);
    text("Minas restantes: "+minasRestantes,15,25);
    
    // Dibuja el tablero
    stroke(0);
    for (int i = 0; i < ancho; i++)
    {
        for (int j = 0; j < alto; j++)
        {
            //Si no hay una mina, muestra el numero con el color correspondiente
            if (tablero[i][j] >= 0 && tablero[i][j] <= 8)
            {
                // Color de fondo despues de presionar el cuadro 
                fill(#001D9D);
                rect(i*20,40+(j*20),20,20);
                
                // select a color based on the number
                switch (tablero[i][j])
                {
                    case 0: fill(250); break;
                    case 1: fill(0,0,190); break;
                    case 2: fill(0,190,190); break;
                    case 3: fill(190,0,0); break;
                    case 4: fill(190,0,190); break;
                    case 5: fill(190,190,0); break;
                    case 6: fill(0,190,0); break;
                    case 7: fill(150,110,90); break;
                    case 8: fill(150); break;
                    default: fill(120); break;
                }
                
                // Muestra el número si no es 0. 0 significa que no hay minas cercanas
                // y no tenemos que poner un número allí. Solo lo deja en blanco.
                if (tablero[i][j] != 0)
                {
                    text(tablero[i][j],6+(i*20),55+(j*20));
                    
                    
                    // Este bit aquí automáticamente reproduce movimientos obvios para que los hagas
                    // el juego va más rápido. Sin embargo, hará que pierdas el juego.
                    // si cree que un movimiento incorrecto es obvio debido a su incorrecta
                    // bandera colocada. Así que tenga cuidado al colocar las banderas incorrectamente.
                    
                    if (countNearbyFlags(i,j) == tablero[i][j])
                    {
                        openNearbySafeSpaces(i,j);
                    }
                }
            }
            // Esto dibuja las banderas como círculos rojos, ya sea que estén colocadas correctamente o no
            else if (tablero[i][j] == 10 || tablero[i][j] == 11)
            {
                fill(190,0,0);
                ellipse(10+(i*20),50+(j*20),20,20);
            }
            // Esta parte dibuja los espacios en los que aún no has cavado como espacios más oscuros.
            else
            {
                fill(60);
                rect(i*20,40+(j*20),20,20);
            }
        }
    }
    
    // IF si el jugador perdió
    if (lcx != -1)
    {
        // Muestra todas las minas
        for (int i = 0; i < ancho; i++)
        {
            for (int j = 0; j < alto; j++)
            {
                if (tablero[i][j] == 9)
                {
                    fill(190,0,0);
                    ellipse(10+(i*20),50+(j*20),20,20);
                }
            }
        }
        // Muestra el movimiento perdedor del juego en morado y también el texto "Intentar de nuevo" en la parte superior        
        fill(#CFD8FF);
        text("Perdiste!, presiona enter para jugar de nuevo",200,25);
        ellipse(10+(lcx*20),50+(lcy*20),20,20);
    }
    
    //Verifica que se haya ganado
    if (minasRestantes == 0)
    {
        // Si tienes banderas falsas, aún no has ganado.
        int banderaFalsa = 0;
        for (int i = 0; i < ancho; i++)
        {
            for (int j = 0; j < alto; j++)
            {
                if (tablero[i][j] == 11)
                {
                    banderaFalsa++;
                }
            }
        }
        
        // Si ninguna de las banderas está mal colocada y no quedan minas, ganas.
        if (banderaFalsa == 0)
        {
            fill(190,0,190);
            text("Ganaste! Presiona enter para jugar de nuevo",200,25);
            victoria = true;
        }
    }
}

void keyPressed()
{
    // 'ENTER' reinicia el juego solo si has ganado o perdido el juego.
    if (keyCode == ENTER && (lcx != -1 || victoria))
    {
        setup();
    }
}

void mousePressed()
{
    // Esta declaración if en el exterior evita la entrada del mouse si se gana o se pierde el juego.
    if (lcx == -1 && !victoria)
    {
        // Para facilitar el cálculo, uso mx y my como variables que reemplazan mouseX y
        // mouseY que básicamente será exactamente igual a la celda a la que apunta el mouse
        // dentro de la matriz del tablero. Básicamente, tu mouse siempre apunta a tablero[mx][my].
        // Sin esto, tendría que escribir tablero[piso(mouseX/20),piso((mouseY-40)/20)] cada vez.
        int mx = floor(mouseX / 20);
        int my = floor((mouseY-40) / 20);
        
        // Esta primera instrucción if evita que golpees una mina en tu primer movimiento y, de hecho,
        // abre el tablero en ese espacio para que siempre tengas un comienzo razonable para tu juego.
        if (primerJugada && mouseButton == LEFT)
        {
            crearZonaSegura(mx,my);
            cavar(mx,my);
            primerJugada = false;
        }
        // Después de que se haya realizado la primera jugada, ahora puedes perder el juego.
        else if (mouseButton == LEFT)
        {
            if (tablero[mx][my] == 9 || tablero[mx][my] == 10)
            {
                juegoPerdido(mx,my);
            }
            else
            {
                cavar(mx,my);
            }
        }
        // Esto es lo que sucede cuando marcas una celda y el juego no te deja marcar nada
        // hasta que hayas hecho tu primer movimiento, porque eso no tendría sentido.
        else if(!primerJugada && mouseButton == RIGHT)
        {
            // Si marca una mina, esa celda se convierte en una celda correctamente marcada.
            if (tablero[mx][my] == 9)
            {
                tablero[mx][my] = 10;
                minasRestantes--;
            }
            // Si marca una celda que no es mía, se convierte en una celda marcada incorrectamente.
            else if (tablero[mx][my] == -1)
            {
                tablero[mx][my] = 11;
                minasRestantes--;
            }
            // Si desmarcas una celda marcada correctamente, quita la bandera y vuelve a poner una mina dentro.
            else if (tablero[mx][my] == 10)
            {
                tablero[mx][my] = 9;
                minasRestantes++;
            }
            // Si desmarca una celda marcada incorrectamente, elimine la bandera y vuelva a colocar un -1 dentro de ella,
            // lo que representa que la celda vuelve a estar abierta y disponible para profundizar.
            else if (tablero[mx][my] == 11)
            {
                tablero[mx][my] = -1;
                minasRestantes++;
            }
        }
    }
}

// Esta es la función que crea una zona segura alrededor de tu primera jugada para que nunca golpees una mina
// en tu primer movimiento, porque nadie tiene tiempo para eso. También elimina las minas de las 8 celdas alrededor.
// su primer movimiento también para que tenga al menos una apertura decente para trabajar y no solo una celda
// abierto con un solo número.
void crearZonaSegura(int x, int y)
{
    // Este bucle for doble es parte de una técnica que estoy usando para mirar todas las celdas alrededor de una celda determinada.
    // Usando este bucle for doble, puedo usar una entrada x de x+i-1, y una entrada y de y+j-1, y como usted
    // ciclo a través de x e y siendo 0, 1 y 2, esas entradas mirarán todas las celdas circundantes.
    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            // Esta declaración if evita que la siguiente fórmula use entradas fuera de los límites de
            // el arreglo tablero para evitar excepciones ArrayOutOfBounds.
            if ((x+i-1) < 0 || (y+j-1) < 0 || (x+i-1) >= 30 || (y+j-1) >= 16)
            {
                continue;
            }
            else
            {
                // Actualice el número total de minas si se eliminó alguna durante este proceso.
                if (tablero[x+i-1][y+j-1] == 9)
                {
                    minasRestantes--;
                }
                // Establece el espacio despejado en el espacio que está listo para abrirse.
                tablero[x+i-1][y+j-1] = -1;
            }
        }
    }
}

// Esta es la función que se usa para excavar en un espacio y ver qué hay allí.
void cavar(int x, int y)
{
    // Yo, you hit a mine.
    if (tablero[x][y] == 9)
    {
        juegoPerdido(x,y);
    }
    
    // If you didn't lose from the above if-statement, then fill in the cell with the number of
    // surrounding mines using the countNearbyMines() function.
    tablero[x][y] = countNearbyMines(x,y);
    
    // Esta es la salsa mágica que continúa abriendo más espacio cuando tiene sentido hacerlo, y convierte esto
    // en un algoritmo recursivo. Si una de las celdas circundantes es un cero, entonces profundice automáticamente en
    // ese espacio y todos los espacios circundantes a ese espacio, recursivamente.
    if (countNearbyMines(x,y) == 0)
    {
        // algoritmo rápido para examinar todas las celdas circundantes, como antes.
        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 3; j++)
            {
                // Comprueba si está fuera de los límites del tablero de juego, como antes.
                if ((x+i-1) < 0 || (y+j-1) < 0 || (x+i-1) >= 30 || (y+j-1) >= 16)
                {
                    continue;
                }
                // Si una celda cercana circundante en la que se podría excavar no tiene una mina y
                // no hay minas a su alrededor, excave en esa también automáticamente a través de la recursividad.
                else if (tablero[x+i-1][y+j-1] == -1 && countNearbyMines(x+i-1,y+j-1) == 0)
                {
                    tablero[x+i-1][y+j-1] = countNearbyMines(x+i-1,y+j-1);
                    cavar(x+i-1,y+j-1);
                }
                // Este bit finaliza este tramo de recursividad cuando encuentra una celda que tiene minas cercanas.
                else
                {
                    tablero[x+i-1][y+j-1] = countNearbyMines(x+i-1,y+j-1);
                }
            }
        }
    }
}

// Esta función simplemente devuelve el número de minas cercanas a una celda.
int countNearbyMines(int x, int y)
{
    int mineCount = 0;
    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            if ((x+i-1) < 0 || (y+j-1) < 0 || (x+i-1) >= 30 || (y+j-1) >= 16)
            {
                continue;
            }
            else
            {
                if (tablero[x+i-1][y+j-1] == 9 || tablero[x+i-1][y+j-1] == 10)
                {
                    mineCount++;
                }
            }
        }
    }
    return mineCount;
}

// Esta función cuenta el número de banderas cercanas a una celda y es importante para
// haciendo los movimientos obvios automáticos.
int countNearbyFlags(int x, int y)
{
    int contadorBanderas = 0;
    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            if ((x+i-1) < 0 || (y+j-1) < 0 || (x+i-1) >= 30 || (y+j-1) >= 16)
            {
                continue;
            }
            else
            {
                if (tablero[x+i-1][y+j-1] == 10 || tablero[x+i-1][y+j-1] == 11)
                {
                    contadorBanderas++;
                }
            }
        }
    }
    return contadorBanderas;
}

// Esta es la función que ejecuta el juego para completar automáticamente los movimientos redundantes, pero
// causar una pérdida de juego si el movimiento redundante se basó en la suposición incorrecta de que su bandera
// se colocó correctamente.
void openNearbySafeSpaces(int x, int y)
{
    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            if ((x+i-1) < 0 || (y+j-1) < 0 || (x+i-1) >= 30 || (y+j-1) >= 16)
            {
                continue;
            }
            else
            {
                // Esto es lo que sucede cuando el movimiento automático tiene éxito.
                if (tablero[x+i-1][y+j-1] == -1)
                {
                    cavar(x+i-1,y+j-1);
                }
                
                // Pero a veces te hace perder porque asume que tu bandera está colocada incorrectamente
                // era una bandera colocada correctamente.
                
                else if (tablero[x+i-1][y+j-1] == 9)
                {
                    juegoPerdido(x+i-1,y+j-1);
                }
            }
        }
    }
}

// Función que conserva la celda que te hizo perder el juego para poder colorearla por separado.
void juegoPerdido(int x, int y)
{
    lcx = x;
    lcy = y;
}

lo script gen_param.sh è stato sviluppato con l'intento di velocizzare alcuni test di Sdc e TEF che richiedono l'utilizzo di coppie Pan/Targa.

I parametri da dare in pasto allo script sono:

	-n -> numero di triple (composte da PAN, TARGA e HEX) che si vogliono generare
	-p -> primi e ultimi caratteri delle targhe da generare
	-o -> parametro opzionale che permette di far partire il numero targa da un valore preciso
	
Ex. bash gen_param.sh	-n 10 -p MARZ -o 100

Lanciato il comando lo script crea,se non esiste, una cartella di destinazione OUT_DIR al cui interno verrà inserito un file .xml contenente le n triple generate. Il pattern utilizzato per la generazione è il seguente:
	PAN: YYYYMMDD...<prg>
	TARGA: MA<prg>RZ

A fine ciclo, scrive su file il tempo di esecuzione dello script (formato date classico) e l'ultimo PRG utilizzato in maniera tale da partire da quel valore in caso di un secondo lancio. Se il current date è diverso dal date dello script, allora il PRG ripartirà da zero. Se si sceglie di far partire il numero targa da un valore a piacere, lo script non prende in considerazione l'ultimo PRG utilizzato.

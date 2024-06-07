.data
HeaderBuf:	.space 56 # Nagłówek pliku .bmp
InputPath: 	.asciz "C:\\Users\\Rafał\\Desktop\\praca praca\\arko\\output.bmp"
ErrorMsg1: 	.asciz "File not found\n"
ErrorMsg2:	.asciz "File BMP must be 24 bits per pixel\n"
AskMsg1:	.asciz "Enter int part of real part of constant multiplied by 2^13\n"
AskMsg2:	.asciz "Enter int part of imaginary part of constant multiplied by 2^13\n"
.eqv	BITS_ON_FRACTION	13
.eqv	WHITE	0xFF
.eqv	BLACK	0x00
.eqv	MAX_ITERATIONS	40
.text
.globl main

main:
################################################################################
# Wykorzystywane rejestry:

# s:

# s0 - wysokość pobrana z pliku
# s1 - szerokość pobrana z pliku
# s2 - file offset pobrany z pliku
# s3 - wielkość pixel array
# s4 - wielkość paddingu
# s5 - real part of constant
# s6 - imaginary part of constant
# s7 - skala o którą się poruszać na szerokości
# s8 - skala o którą się poruszać na wysokości
# s9 - startowa wartość real part of complex number po zaczęciu nowego wiersza
# s10 - aktualny adres sterty
# s11 - zapisany addres do sterty

# t w pętlach w których zmieniamy pixele:

# t0 - tymczasowa wysokość
# t1 - tymczasowa szerokość
# t2 - wartość imaginary part of complex number którą ma pixel
# t3 - wartość real part of complex number którą ma pixel
# t4 - aktualna ilość iteracji pętli julia_check
# t5 - wartość imaginary part of complex number w ciągu rekurencyjnym
# t6 - wartość real part of complex number w ciągu rekurencyjnym

# a:

# a7 - przechowuje kod koloru który należy do Julii
# a6 - przechowuje kod koloru białego który nie należy do Julii
# a5 - przechowuje wartość BITS_ON_FRACTION - 1
# a4 - wartość 4, która jest potrzebna przy warunku wyjścia z pętli
# a3 i a2 jest wykorzystywane przy ciągu rekurencyjnym
################################################################################

	# -- Poproś usera o dane -- #
	la a0, AskMsg1 #
	jal print_message
	jal read_int

	mv s5, a0		# s5 = re_part const

	la a0, AskMsg2
	jal print_message
	jal read_int

	mv s6, a0		# s6 = im_part const

	# -- Koniec proszenia o dane -- #
	# -- Początek czytania pliku -- #
	li a7, 1024
	li a1, 0
	la a0, InputPath
	ecall				# Otwórz plik

	mv t2, a0			# t2 = file description

	la a0, ErrorMsg1		# Wczytaj error message
	blt t2, zero, print_error	# Sprawdź, czy znaleziono plik


	li a7, 63
	mv a0, t2
	la a1, HeaderBuf  	# a1 =  HeaderBuf
	addi a1, a1, 2     	# Dodaj 2 - padding
	li a2, 54          	# a2 = 54 - standardowy rozmiar nagłówka
	ecall             	# Odczytaj nagłówek

	lw s1, 18(a1)     	# s1 = width
	lw s0, 22(a1)      	# s0 = height
	lw t1, 2(a1)       	# t1 = wielkość pliku
	lw s2, 10(a1)     	# s2 = file offset
	lh t3, 28(a1)      	# t3 = pixel per bits

	li t0, 24
	la a0, ErrorMsg2
	bne t0, t3, print_error # Sprawdź, czy .bmp jest 24 bitowy

	sub s3, t1, s2      	# s3 = rozmiar pixel array


	li a7, 9
	mv a0, s3
	ecall             	# Alokuj pamięć dla pixel array

	mv s11, a0         	# s11 = adres do alokowanej pamięci

	li a7, 63
	mv a0, t2
	mv a1, s11
	mv a2, s3
	ecall            	# Push pixel array na heapa

	li a7, 57
	mv a0, t2        	# Zamknij plik
	ecall

	# -- Koniec czytania pliku -- #
	# -- Start obliczania fraktala -- #
	andi s4, s1, 3   	# padding = width % 4

	li t0, 3            # 2 * 1,5 ( x i y min = -1.5, x i y max = 1.5)
	slli t0, t0, BITS_ON_FRACTION

	div s7, t0, s1    	# s7 = width scale
	div s8, t0, s0   	# s8 = height scale

	li a5, BITS_ON_FRACTION
	addi a5, a5, -1		# a5 = BITS_ON_FRACTION -1

	li s9, -3			# s9 = -1,5 * 2
	sll s9, s9, a5  	# s9 = const re_part
	mv t2, s9			# t2 = const im_part
	add t2, t2, s8      # Przywróć odjęte wcześniej skalowanie

	mv t0, s0        	# t0 = x_temp
	addi t0, t0, 1   	# Dodaj odjęte wcześniej 1


	li a7, BLACK    	# a7 = czarny piksel
	li a6, WHITE    	# a6 = biały piksel

	li t4, MAX_ITERATIONS	# t4 = iteration
	li a4, 4			# a4 = max complex modul^2
	slli a4, a4, BITS_ON_FRACTION

	mv s10, s11       	# s10 = adres sterty

	# -- Koniec liczenia Fraktala -- #
# -------------------- Start pętli wysokości ------------------------------------------- #
height_loop:

	mv t1, s1          	# t1 = x_temp
	mv t3, s9        	# t3 = imp_part

	addi t0, t0, -1   	# Odejmij jeden rząd
	add t2, t2, s8

 	beqz t0, write_to_file
# --------------------- Koniec pętli wysokości ----------------------------------------- #
# ------------------- Start pętli prepare_to_pixel_check ------------------------------- #
prepare_to_pixel_check:
	li t4, MAX_ITERATIONS	# t4 = iteration

	mv t5, t2		# t5 = im_part
	mv t6, t3		# t6 = re_part

#-------------------- Koniec pętli prepare_to_pixel_check -----------------------------#
#--------------------- Start pętli pixel_check -----------------------------------------#
pixel_check:
      #		newRe = oldRe * oldRe - oldIm * oldIm + cRe;
      #		newIm = 2 * oldRe * oldIm + cIm;
      #		if((newRe * newRe + newIm * newIm) > 4) break;

      # -- Oblicz nowy re_part -- #
      mul a3, t6, t6   		# oldRe * oldRe
      srai a3, a3, BITS_ON_FRACTION

      mul a2, t5, t5   		# oldIm * oldIm
      srai a2, a2, BITS_ON_FRACTION
      sub a3, a3, a2   		# oldRe * oldRe - oldIm * oldIm
      add a3, a3, s5   		# oldRe * oldRe - oldIm * oldIm + cRe;

      # --C Oblicz nowy im_part -- #
      mul t5, t5, t6 		# oldIm * oldRe
      sra t5, t5, a5 		# 2 * oldRe * oldIm
      add t5, t5, s6 		# 2 * oldRe * oldIm + cIm

      mv t6, a3      		# assign new Re to t6

      # -- Oblicz moduł -- #

      mul a2, t6, t6 		# newRe * newRe
      srai a2, a2, BITS_ON_FRACTION
      mul a3, t5, t5		# newIm * newIm
      srai a3, a3, BITS_ON_FRACTION
      add a3, a3, a2		# newRe * newRe + newIm * newIm

      bgt a3, a4, non_julia_pixel  # Jeżeli moduł > 4 go to non_julia_pixel

      addi t4, t4, -1

      bnez t4, pixel_check


# -------------------- Koniec pętli pixel_check --------------------------------------- #
# ------------------- Początek pętli julia_pixel -------------------------------------- #
julia_pixel:
	sb a7, (s10)
	sb a7, 1(s10)
	sb a7, 2(s10)

	addi s10, s10, 3	# Ustaw adres sterty na kolejny 3bajtowy piksel
	b width_loop
# ------------------- Koniec pętli julia_pixel ---------------------------------------- #
# ------------------ Początek pętli non_julia_pixel ----------------------------------- #
non_julia_pixel:

	sb a6, (s10)
	sb a6, 1(s10)
	sb a6, 2(s10)

	addi s10, s10, 3	# Ustaw adres sterty na kolejny 3bajtowy piksel

# ------------------ Koniec pętli non_julia_pixel ------------------------------------- #
# -------------------- Początek pętli width_loop -------------------------------------- #
width_loop:
	addi t1, t1, -1        # Odejmij szerokość
	add t3, t3, s7         # Dodaj skalę wysokości

	bnez t1, prepare_to_pixel_check     # Jeżeli x_temp != 0 go to preapre_to_pixel_check else go to padding

# -------------------- Koniec pętli width_loop ---------------------------------------- #
# -------------------- Początek pętli add_padding ------------------------------------- #
add_padding:
	add s10, s10, s4    	# Dodaj padding do sterty

	b height_loop

# ------------------- Koniec pętli add_padding ---------------------------------------- #
# ------------------- Początek pętli write_to_file ------------------------------------ #
write_to_file:
	li a7, 1024
	li a1, 1
	la a0, InputPath
	ecall			# Otwórz plik

	mv t0, a0		# t0 = file id

	li a7, 64		# Zapisz w nagłówku
	la a1, HeaderBuf
	addi a1, a1, 2
	mv a2, s2
	ecall

	li a7, 64		# Zapisz do pliku pixel array
	mv a0, t0
	mv a1, s11
	mv a2, s3
	ecall

	li a7, 57
	mv a0, t0
	ecall			# Zamknij plik

# ------------------- Koniec pętli write_to_file -------------------------------------- #
# ------------------- Koniec pętli START of end --------------------------------------- #
end:
	li a7, 10
	ecall			# Zakończ program
# ------------------- Koniec pętli end ------------------------------------------------ #
# -------------------- Początek pętli print_error-------------------------------------- #
print_error:
	jal print_message

	b end			# Go to end
# -------------------- Koniec pętli print_error --------------------------------------- #
# ------------------- Początek pętli print_message------------------------------------- #
print_message:
	li a7, 4
	ecall

	ret
# -------------------- Koniec pętli print_message-------------------------------------- #
# -------------------- Początek pętli read_int----------------------------------------- #
read_int:
	li a7, 5
	ecall

	ret
# ------------------- Koniec pętli read_int-------------------------------------------- #

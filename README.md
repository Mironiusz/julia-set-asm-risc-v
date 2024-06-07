
# Julia Set Generator

### Autor: Rafał Mironko

---

## Opis projektu

**Julia Set Generator** to program napisany w assemblerze RISC-V, który generuje bitmapę zbioru Julii na podstawie otrzymanych danych początkowych. Program prosi użytkownika o wprowadzenie części rzeczywistej i urojonej stałej, a następnie generuje obraz fraktala Julii w formacie .bmp.

## Algorytm Julii

Zbiór Julii jest generowany na podstawie iteracji funkcji zespolonej. Dla każdego punktu \((x, y)\) w płaszczyźnie zespolonej, iteracja przebiega według wzoru:

\[
z_{n+1} = z_n^2 + c
\]

gdzie \(z\) jest liczbą zespoloną, a \(c\) jest stałą zespoloną określoną przez użytkownika. Początkowo \(z_0\) jest równe współrzędnym punktu \((x, y)\). Jeśli ciąg \(|z_n|\) nie przekroczy pewnej granicy (np. 2) po określonej liczbie iteracji, punkt \((x, y)\) jest częścią zbioru Julii.

## Funkcje

- **Generowanie Zbioru Julii**: Program oblicza i generuje fraktal Julii.
- **Interaktywne Dane Wejściowe**: Użytkownik wprowadza część rzeczywistą i urojoną stałej zespolonej.
- **Wysoka Wydajność**: Wykorzystanie assemblera RISC-V pozwala na maksymalizację wydajności podczas generowania fraktala.

## Wymagania

- **RARS (RISC-V Assembler and Runtime Simulator)**: Do kompilacji i uruchomienia programu.
- **Program do przeglądania obrazów .bmp**: Do otwarcia wygenerowanego pliku output.bmp.

## Instalacja

1. **Pobierz i zainstaluj RARS**: [Pobierz RARS](https://github.com/TheThirdOne/rars/releases).
2. **Sklonuj repozytorium**:
   ```sh
   git clone https://github.com/twoje_repozytorium/julia-set-generator.git
   cd julia-set-generator
   ```

## Użycie

1. Otwórz plik assemblera w RARS.
2. Uruchom program, aby wygenerować plik `output.bmp`.
3. Otwórz `output.bmp` za pomocą dowolnego programu do przeglądania obrazów.

## Autor

Rafał Mironko

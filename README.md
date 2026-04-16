# 7. Uloha DE_1 Pong

Hra je zobrazena na 2 LED maticích 8×8, které spolu tvoří hrací plochu 16×8.

## Vstupy

clk - systémový hodinový signál  
rst - reset systému

btnl - pohyb pálky hráče 1 nahoru  
btnd - pohyb pálky hráče 1 dolů  
btnu - pohyb pálky hráče 2 nahoru  
btnr - pohyb pálky hráče 2 dolů

## Výstupy

data_out - sériová datová linka pro MAX7219  
clk_out - hodinový signál pro přenos dat  
cs1 - výběr prvního LED driveru  
cs2 - výběr druhého LED driveru

## Popis

Program zpracovává tlačítka obou hráčů, řídí pohyb pálek a míčku a vytváří obraz hry pro LED matice.

Míček se pohybuje po hrací ploše, odráží se od stěn a od pálky. Pokud hráč míček netrefí, bod získá protihráč.

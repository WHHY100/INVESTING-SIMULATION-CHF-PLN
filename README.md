# INVESTING-SIMULATION-CHF-PLN

* [Dane](#Dane)
* [Opis działania skryptu](#Opis)
* [Prezentacja wyników](#Wizualizacja)
* [Wykorzystana technologia](#Technologia)

## Dane

Dane o historycznych kursach walut wykorzystywane w projekcie zostały pobrane z archiwum NBP.

URL: https://www.nbp.pl/home.aspx?f=/kursy/arch_a.html

## Opis

W pierwszej częsci skryptu pobierane są dane średniego miesięcznego kursu Franka szwajcarskiego z archiwum NBP w latach 2012 - 2021.

W kolejnej częsci programu przeprowadzana jest symulacja oszczędzania w złotówkach przy założeniu oprocentowania depozytu w na
poziomie 3.5%, z kapitalizacją miesieczną. W symulacji wzięty jest także pod uwagę podatek belki, który w badanym okresie wynosił 19%.

W następnej części skryptu badana jest efektywność oszczędzania we Frankach szwajcarskich. Symulacja zakłada comiesięczną wymianę PLN na CHF 
po średnim miesięcznym kursie obowiązującym w danym okresie. Depozyt jest nieoprocentowany.

Oba warianty zakładają wpłaty na poziomie 500zł miesięcznie w badanym okresie.

## Wizualizacja

![CHF_PLN img](https://github.com/WHHY100/INVESTING-SIMULATION-CHF-PLN/blob/main/RESULT/LAST_YEAR.jpg?raw=true)

Powyższa tabela prezentuje ostatni rok oszczędzania w dwóch opisanych wcześniej wariantach. Jeżeli w latach 2012-2021 zdecydowalibyśmy się na oszczędzanie 
w złotówkach na depozycie oprocentowanym na poziomie 3.5% na koniec badanego okresu posiadalibyśmy 69 275,18zł. Z kolei przy wariancie wymiany PLN na CHF 
po średniomiesięcznym kursie, w ostatnim badanym miesiącu posiadalibyśmy 70 406,00zł. 

Powyżej opisana symulacja zachodzi, ponieważ mimo okresowych wahań kursu franka względem złotówki, da się zauważyć systematyczne umacnianie się 
szwajcarskiej waluty. Trend jest na tyle wyraźny, że mimo braku oprocentowania w badanym okresie korzystniej byłoby wybrać drugi wariant oszczędzania.

Należy również zauważyć, że kursy walut są płynne i w kolejnych okresach Frank szwajcarski mógłby się osłabić co spodowałoby nieoplacalność tego wariantu. 
(jak wiemy na dzień 09-07-2022 tak się nie stało i Frank szwajcarski dalej się umacniał).

Opłacalność oszczędzania w złotowkach, w badanym okresie, pojawia się dopiero wtedy gdy depozyt jest oprocentowany na minimum 4% (z kapitalizacją 
miesięczną).

Pełny raport z symulacji:
https://github.com/WHHY100/INVESTING-SIMULATION-CHF-PLN/blob/main/RESULT/FULL_REPORT.pdf

## Technologia

*SAS Studio* ® w SAS® OnDemand

Wersja: *9.4_M6*

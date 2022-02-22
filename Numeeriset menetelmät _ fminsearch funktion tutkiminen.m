%% BM20A1501 Numeeriset menetelm�t I 
% * Harjoitusty� 2021
% * Leevi K�m�r�inen
% * Opiskelijanumero 0568396

%% Suunnitelma ja deadlinet
% * Suunnitelma 12.4.2021
% Aion tarkastella harjoitusty�ss�ni fminsearch-funktion toimintaa.
% Alustavasti ensin tarkastelen funktion dokumentaation huolella l�pi. Sen
% j�lkeen empiirist� tutkimusta erilaisin funktioin tai minivoitavin
% ongelmin. K�yn my�s l�pi funktion koodia (open fminsearch) ja yrit�n ymm�rt�� parhaani
% mukaan sen toimintaa. 
%
% * V�lipalautus: 25.4.2021
%
% * Loppupalautus: 9.5.2021.

%% Ty�n aihe
% Fminsearch on matlabissa oleva funktio,jonka avulla voidaan ratkaista
% jonkin ongelman minimej�, esimerkiksi funktion minimikohtia.
% Fminsearchia on hyv� k�ytt�� sill� se voi ratkaista funktion minimikohtia
% ilman ett� tarvitsee tiet�� funktion derivaattafunktiota.

%% Johdatus
%
% Fminsearch toimii Nelder-Mead algoritmin mukaisesti. Algoritmiss� on
% seuraavia operaatioita, joilla se etsii minimikohtaa:

url_img = imread('https://hsto.org/web/7c7/7a5/704/7c77a5704e5b4ab7b9cae626b995c152.png');
imshow(url_img) %Kuvan lataaminen netist�.
%%
% L�hde: https://sudonull.com/post/69185-Nelder-Mead-optimization-method-Python-implementation-example
%
% Algoritmiss� siis ensiksi generoidaan alustava simplexi lis��m�ll� 5%
% jokaiseen alkuarvauksen komponenttiin x0.(L�hde:
% https://se.mathworks.com/help/optim/ug/fminsearch-algorithm.html).
% 
% Simplexin arvot j�rjestet��n j�rjestykseen jossa $f(x(1)) < f(x(2)) < ...
% < f(x(n+1))$
%
% Yksi algoritmin operaatioista on heijastus (reflection), miss� lasketaan simplexin
% huonoimman pisteen peilikuvana oleva piste r. T�m� tapahtuu ottamalla
% keskipiste (merkit��n m:ll�) kahden pienimm�n funktion arvon tuottavan simplexin
% p��tepisteen v�list� (f(x(1), f(x(n))) ja peilaamalla t�m�n keskipisteen kautta suurimman
% funktion arvon tuottavan simplexi p��tepiste f(x(n+1)) . Jos saatu peilattu pisteen
% r funktion arvo f(r) on arvojen f(x(1)) ja f(x(n)) (ehto (1)) niin hyv�ksyt��n t�m�
% iteraatio ja toteutetaan heijastus.
% 
% Jos edellinen ehto ei toteudu mutta f(r) on pienempi kuin f(x(1))(ehto (2)) niin
% lasketaan arvo laajennus (expansion) operaatio varten ja merkit��n t�t� pistett�
% kirjaimella s. Jos f(s) on pienempi kuin f(r) niin hyv�ksyt��n t�m�
% iteraatio ja toteutetaan operaatio laajennus.
% 
% Jos ehto (1) tai (2) mutta $f(r) \geq  f(x(n))$ toteutetaan supistus (contraction) m:n ja
% x(n+1) tai r:n v�lill�. Jos $f(r) \geq f(x(n+1))$ niin
% lasketaan supistamista varten piste c, joka on m:n ja r:n v�lill�. Jos
% p�tee $f(x) < f(r)$ hyv�ksyt��n piste c eli toteutetaan supistus ulosp�in.
%
% Jos p�tee $f(r) \leq f(x(n+1))$ niin lasketaan piste cc joka on m:n ja
% x(n+1) pisteen v�lill�. Jos p�tee $f(cc) < f(x(n+1))$ hyv�ksyt��n piste cc
% eli toteutetaan supistus sis��np�in.
%
% Jos kumpikaan supistuksen ehdoista ei toteudu niin toteutetaan nykyisille
% pisteille kutistaminen (shrink). Nykyinen jana miss� keskipisteen� on m,
% pysyy saman pituisena mutta muut simplexin janat muutetaan lyhyemmiksi.

%% Matlab-ratkaisu
clearvars;close all;clc
% Matlab-koodit.
% Etsit��n funktion f(x) = x^2 -2x minimi (tiedet��n ett� se on 1,-1),
% alkuarvauksella 1
f = @(x) x^2 - 2*x;
% Etsit��n minimi funktiolle. Fminsearch palauttuu minimin x-arvon, y-arvo
% saadaan ratkaistua sijoittamalla se funktioon.
minimix = fminsearch(f,1);
minimiy = f(minimix);

% Testataan kahden muuttujan tapauksessa fminsearchia pisteiden piirron
% kanssa:
figure
f21 = @(x,y) x.^2 + y.^2;
f2 = @(x) x(1).^2 + x(2).^2; %fminsearchia varten vektorimuotoinen funktio
[A, B] = meshgrid(-5:0.01:5);
%Piirret��n kuvaaja
[xymin1, zmin1,data] = fmins(f2,[4 4]);


%Esimerkki koodi
y1 = @(x) sin(x);
x1 = -pi:.01:pi;
x01 = 0;
[xmin1, ymin1,data1] = fmins(y1, x01);

y2 = @(x) sin(x);
x2 = 30*pi:.01:42*pi;
x02 = 36*pi;
[xmin2, ymin2, data2] = fmins(y2,x02);

%% Tulokset

%Ensimm�isen kohdan piirrot: 
hold on
title('Funktion x^2 + y^2 minimi alkuarvauksella [4 4]')
view(-12,49) 
mesh(A,B,f21(A,B))
plot3(xymin1(1), xymin1(2),zmin1,'r*')
plot3(4,4,f21(4,4),'ro')
plot3(data(:,1),data(:,2),f21(data(:,1),data(:,2)),'-k','LineWidth',2)
xlabel('x');ylabel('y')
legend('Funktio x^2 + y^2','Minimikohta','Aloituspiste','Algoritmin eteneminen')


% Tarkastellaan korkeusk�yr��:
figure
hold on
title('Funktion x^2 + y^2 korkeusk�yr�')
contour(A,B,f21(A,B))
plot(data(:,1),data(:,2),'k-')
plot3(xymin1(1), xymin1(2),zmin1,'r*')
xlabel('x');ylabel('y')
legend('Korkeusk�yr� funktiolle x^2 + y^2','Algoritmin eteneminen','Minimikohta','Location','SouthWest')
% Huomataan ett� fminsearchilla suorat l�htee siirtym��n kohti korkeusk�yr�n
% matalinta kohtaa (loogista sill� minimikohtaa haluammekin etsi�).

% Esimerkki koodin kuvaajat:
figure
plot(x1, y1(x1));  hold on
plot(xmin1, y1(xmin1), 'r*')
plot(x01, y1(x01),'ro')
plot(data1,sin(data1),'k-')
xlabel('x');ylabel('y')
title('L�ytyy l�hin ratkaisu:')
legend('Funktio sin(x)','Minimikohta','Aloituspiste','Algoritmin eteneminen')

figure
plot(x2, y2(x2)); hold on
plot(xmin2, y2(xmin2), 'r*');
plot(x02, y2(x02),'ro')
plot(data2,y2(data2),'k-')
xlabel('x');ylabel('y')
legend('Funktio sin(x)','Minimikohta','Aloituspiste','Algoritmin eteneminen')
title('Ei l�ydy l�hint� ratkaisua')
hold off

%% Johtop��t�s
%
% Fminsearch funktio toimii hy�dynt�en Nelder-Mead optimointi algoritmi�.
% Matlabissa sen aloitus toimii laskemalla alkuarvauksesta 5% ja lis��m�ll� t�m�n alkuarvauksen 5% jokaiseen alkuarvauksen alkioon. N�in muodostuvaa vektorikuviota kutsutaan simplexiksi. Esimerkkitiedoston tapauksessa
% kun alkuarvaus on $36 \cdot \pi \approx 113.10$, viisi prosentia eteenp�in t�st�
% saadaan arvoksi $1.05 \cdot 36 \cdot \pi \approx 118.75$ ja viisi prosentia taakse
% p�in saadaan arvoksi $0.95 \cdot 36 \cdot \pi \approx 107.44$. N�ill� arvoilla kun
% lasketaan funktion arvot saadaan $f(118.75) \approx -0.5896$ ja $f(107.44)
% \approx 0.5858$. N�ist� arvoista pienemm�n funktion arvon tuottaa
% x:n arvo 118.75. Kuvasta kuitenkin huomataan ett� l�hin minimi sijaitsee
% kuitenkin juuri toisessa suunnassa, eli jos oltaisiin valittu 107.44.
% T�st� voidaan p��tell� ett� algoritmin k�ytt� ei toimi hyvin tihe�sti
% aaltoilevalle funktiolle, sill� 5% x:n arvon muutoksella voidaan p��st�
% hyvin pitk�lle l�himm�st� minimist�. 

%% Funktiot
%Tarkoitus t��lt� my�s korjata viel� kuvien publishaus oikeaan kohtaan.
function [min, fval, data] = fmins(fun,x0)
%fmins on modifoitu funktio fminsearchista. Sen avulla voidaan tehd�
%funktiolle fminsearch toimenpide, mutta se samalla tallentaa jokaisen
%iteraation tuottamat datapisteiden arvot. Output-muuttujaan min se
%tallentaa minimi arvon, ja fvaliin sit� vastaavan funktioarvon. Data
%muuttujaan tallennetaan jokaisen iteraation tuottama minimiarvo.
    data = []; %Dataan tallennetaan jokaisen fminsearch iteraation ratkaisemat datapisteet.
    options = optimset('OutputFcn',@outfun); %Tarvitaan options muuttuja jotta saadaan jokaisella iteraatiolla tehty� haluttavat toimenpiteet
    [min, fval] = fminsearch(fun,x0,options);%Fminsearch
    function stop = outfun(x,optimValues,state);
     stop=false; %Tarkistaa onko iteraatioita viel� tulossa.
     if isequal(state,'iter') %Tarkistetaan onko varmasta iteraatio vaihe k�ynniss�
        data = [data; x]; %Tallennetaan dataan pisteet.
     end
    end
end

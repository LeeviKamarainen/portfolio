%% BM20A1501 Numeeriset menetelmät I 
% * Harjoitustyö 2021
% * Leevi Kämäräinen
% * Opiskelijanumero 0568396

%% Suunnitelma ja deadlinet
% * Suunnitelma 12.4.2021
% Aion tarkastella harjoitustyössäni fminsearch-funktion toimintaa.
% Alustavasti ensin tarkastelen funktion dokumentaation huolella läpi. Sen
% jälkeen empiiristä tutkimusta erilaisin funktioin tai minivoitavin
% ongelmin. Käyn myös läpi funktion koodia (open fminsearch) ja yritän ymmärtää parhaani
% mukaan sen toimintaa. 
%
% * Välipalautus: 25.4.2021
%
% * Loppupalautus: 9.5.2021.

%% Työn aihe
% Fminsearch on matlabissa oleva funktio,jonka avulla voidaan ratkaista
% jonkin ongelman minimejä, esimerkiksi funktion minimikohtia.
% Fminsearchia on hyvä käyttää sillä se voi ratkaista funktion minimikohtia
% ilman että tarvitsee tietää funktion derivaattafunktiota.

%% Johdatus
%
% Fminsearch toimii Nelder-Mead algoritmin mukaisesti. Algoritmissä on
% seuraavia operaatioita, joilla se etsii minimikohtaa:

url_img = imread('https://hsto.org/web/7c7/7a5/704/7c77a5704e5b4ab7b9cae626b995c152.png');
imshow(url_img) %Kuvan lataaminen netistä.
%%
% Lähde: https://sudonull.com/post/69185-Nelder-Mead-optimization-method-Python-implementation-example
%
% Algoritmissä siis ensiksi generoidaan alustava simplexi lisäämällä 5%
% jokaiseen alkuarvauksen komponenttiin x0.(Lähde:
% https://se.mathworks.com/help/optim/ug/fminsearch-algorithm.html).
% 
% Simplexin arvot järjestetään järjestykseen jossa $f(x(1)) < f(x(2)) < ...
% < f(x(n+1))$
%
% Yksi algoritmin operaatioista on heijastus (reflection), missä lasketaan simplexin
% huonoimman pisteen peilikuvana oleva piste r. Tämä tapahtuu ottamalla
% keskipiste (merkitään m:llä) kahden pienimmän funktion arvon tuottavan simplexin
% päätepisteen välistä (f(x(1), f(x(n))) ja peilaamalla tämän keskipisteen kautta suurimman
% funktion arvon tuottavan simplexi päätepiste f(x(n+1)) . Jos saatu peilattu pisteen
% r funktion arvo f(r) on arvojen f(x(1)) ja f(x(n)) (ehto (1)) niin hyväksytään tämä
% iteraatio ja toteutetaan heijastus.
% 
% Jos edellinen ehto ei toteudu mutta f(r) on pienempi kuin f(x(1))(ehto (2)) niin
% lasketaan arvo laajennus (expansion) operaatio varten ja merkitään tätä pistettä
% kirjaimella s. Jos f(s) on pienempi kuin f(r) niin hyväksytään tämä
% iteraatio ja toteutetaan operaatio laajennus.
% 
% Jos ehto (1) tai (2) mutta $f(r) \geq  f(x(n))$ toteutetaan supistus (contraction) m:n ja
% x(n+1) tai r:n välillä. Jos $f(r) \geq f(x(n+1))$ niin
% lasketaan supistamista varten piste c, joka on m:n ja r:n välillä. Jos
% pätee $f(x) < f(r)$ hyväksytään piste c eli toteutetaan supistus ulospäin.
%
% Jos pätee $f(r) \leq f(x(n+1))$ niin lasketaan piste cc joka on m:n ja
% x(n+1) pisteen välillä. Jos pätee $f(cc) < f(x(n+1))$ hyväksytään piste cc
% eli toteutetaan supistus sisäänpäin.
%
% Jos kumpikaan supistuksen ehdoista ei toteudu niin toteutetaan nykyisille
% pisteille kutistaminen (shrink). Nykyinen jana missä keskipisteenä on m,
% pysyy saman pituisena mutta muut simplexin janat muutetaan lyhyemmiksi.

%% Matlab-ratkaisu
clearvars;close all;clc
% Matlab-koodit.
% Etsitään funktion f(x) = x^2 -2x minimi (tiedetään että se on 1,-1),
% alkuarvauksella 1
f = @(x) x^2 - 2*x;
% Etsitään minimi funktiolle. Fminsearch palauttuu minimin x-arvon, y-arvo
% saadaan ratkaistua sijoittamalla se funktioon.
minimix = fminsearch(f,1);
minimiy = f(minimix);

% Testataan kahden muuttujan tapauksessa fminsearchia pisteiden piirron
% kanssa:
figure
f21 = @(x,y) x.^2 + y.^2;
f2 = @(x) x(1).^2 + x(2).^2; %fminsearchia varten vektorimuotoinen funktio
[A, B] = meshgrid(-5:0.01:5);
%Piirretään kuvaaja
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

%Ensimmäisen kohdan piirrot: 
hold on
title('Funktion x^2 + y^2 minimi alkuarvauksella [4 4]')
view(-12,49) 
mesh(A,B,f21(A,B))
plot3(xymin1(1), xymin1(2),zmin1,'r*')
plot3(4,4,f21(4,4),'ro')
plot3(data(:,1),data(:,2),f21(data(:,1),data(:,2)),'-k','LineWidth',2)
xlabel('x');ylabel('y')
legend('Funktio x^2 + y^2','Minimikohta','Aloituspiste','Algoritmin eteneminen')


% Tarkastellaan korkeuskäyrää:
figure
hold on
title('Funktion x^2 + y^2 korkeuskäyrä')
contour(A,B,f21(A,B))
plot(data(:,1),data(:,2),'k-')
plot3(xymin1(1), xymin1(2),zmin1,'r*')
xlabel('x');ylabel('y')
legend('Korkeuskäyrä funktiolle x^2 + y^2','Algoritmin eteneminen','Minimikohta','Location','SouthWest')
% Huomataan että fminsearchilla suorat lähtee siirtymään kohti korkeuskäyrän
% matalinta kohtaa (loogista sillä minimikohtaa haluammekin etsiä).

% Esimerkki koodin kuvaajat:
figure
plot(x1, y1(x1));  hold on
plot(xmin1, y1(xmin1), 'r*')
plot(x01, y1(x01),'ro')
plot(data1,sin(data1),'k-')
xlabel('x');ylabel('y')
title('Löytyy lähin ratkaisu:')
legend('Funktio sin(x)','Minimikohta','Aloituspiste','Algoritmin eteneminen')

figure
plot(x2, y2(x2)); hold on
plot(xmin2, y2(xmin2), 'r*');
plot(x02, y2(x02),'ro')
plot(data2,y2(data2),'k-')
xlabel('x');ylabel('y')
legend('Funktio sin(x)','Minimikohta','Aloituspiste','Algoritmin eteneminen')
title('Ei löydy lähintä ratkaisua')
hold off

%% Johtopäätös
%
% Fminsearch funktio toimii hyödyntäen Nelder-Mead optimointi algoritmiä.
% Matlabissa sen aloitus toimii laskemalla alkuarvauksesta 5% ja lisäämällä tämän alkuarvauksen 5% jokaiseen alkuarvauksen alkioon. Näin muodostuvaa vektorikuviota kutsutaan simplexiksi. Esimerkkitiedoston tapauksessa
% kun alkuarvaus on $36 \cdot \pi \approx 113.10$, viisi prosentia eteenpäin tästä
% saadaan arvoksi $1.05 \cdot 36 \cdot \pi \approx 118.75$ ja viisi prosentia taakse
% päin saadaan arvoksi $0.95 \cdot 36 \cdot \pi \approx 107.44$. Näillä arvoilla kun
% lasketaan funktion arvot saadaan $f(118.75) \approx -0.5896$ ja $f(107.44)
% \approx 0.5858$. Näistä arvoista pienemmän funktion arvon tuottaa
% x:n arvo 118.75. Kuvasta kuitenkin huomataan että lähin minimi sijaitsee
% kuitenkin juuri toisessa suunnassa, eli jos oltaisiin valittu 107.44.
% Tästä voidaan päätellä että algoritmin käyttö ei toimi hyvin tiheästi
% aaltoilevalle funktiolle, sillä 5% x:n arvon muutoksella voidaan päästä
% hyvin pitkälle lähimmästä minimistä. 

%% Funktiot
%Tarkoitus täältä myös korjata vielä kuvien publishaus oikeaan kohtaan.
function [min, fval, data] = fmins(fun,x0)
%fmins on modifoitu funktio fminsearchista. Sen avulla voidaan tehdä
%funktiolle fminsearch toimenpide, mutta se samalla tallentaa jokaisen
%iteraation tuottamat datapisteiden arvot. Output-muuttujaan min se
%tallentaa minimi arvon, ja fvaliin sitä vastaavan funktioarvon. Data
%muuttujaan tallennetaan jokaisen iteraation tuottama minimiarvo.
    data = []; %Dataan tallennetaan jokaisen fminsearch iteraation ratkaisemat datapisteet.
    options = optimset('OutputFcn',@outfun); %Tarvitaan options muuttuja jotta saadaan jokaisella iteraatiolla tehtyä haluttavat toimenpiteet
    [min, fval] = fminsearch(fun,x0,options);%Fminsearch
    function stop = outfun(x,optimValues,state);
     stop=false; %Tarkistaa onko iteraatioita vielä tulossa.
     if isequal(state,'iter') %Tarkistetaan onko varmasta iteraatio vaihe käynnissä
        data = [data; x]; %Tallennetaan dataan pisteet.
     end
    end
end

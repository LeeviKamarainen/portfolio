%% Kandidaatintyö 
%Luetaan CSV-data matriisiin

data = readmatrix('data2.xlsx','Sheet','Data','Range','E1:BM244331');
%Vuodet

finland_population = data(106589,:)
years = data(1,:);

%Datan luku
%%

%Naisten ikä populaatiot

%37017:37033
female_age_population = data(37017,5:end)

%plot(years,female_age_population)

hold on
agespan = 0
for i = 37017:1:37033
    plot(years,data(i,5:60),'.')
    titletext = "Ages: "+agespan+" - "+(agespan+4);
    title(titletext)
    %figure
    hold on
    agespan = agespan+5;
end


%% Testailua
%Suomen populaatio vuosilta 1960-2020
close all;clc
finland_population = data(106589,:)
%
subplot(2,2,1)
plot(years,finland_population);
pop_plot('Alkuperäinen data')

%Poistetaan satunnaisesti 10 vuotta populaatio dataa
randpop = randi([1, length(years)],1,10);
del_fin_pop = finland_population;
del_fin_pop(randpop) = nan;

%Piirretään poistetun datan kuvaaja
% figure
subplot(2,2,2)
plot(years,del_fin_pop)
pop_plot('Poistettu data')

%Korjataan data ympäröivillä arvoilla (ensimmäinen ja viimeinen arvo ottaa
%lähimmän löytyvän arvon)
%Kopoiodaan poistettu data uuteen muuttujaan
fix_fin_pop = del_fin_pop;

for i = 1:length(years)
    if(i==1)%Ensimmäinen arvo
       j=i;
       while(isnan(fix_fin_pop(j)))
           j=i+1;
       end
       fix_fin_pop(i) = fix_fin_pop(j);
    elseif(i==length(years))%Viimeinen arvo
       j=i;
       while(isnan(fix_fin_pop(j)))
           j=i-1;
       end
       fix_fin_pop(i) = fix_fin_pop(j);
    elseif(isnan(fix_fin_pop(i)))
       prev = fix_fin_pop(i-1);%Edellinen arvo 
       j=i;
       while(isnan(fix_fin_pop(j)))
           j=j+1;
       end
       next = fix_fin_pop(j);
       avg = (prev+next)/2;
       fix_fin_pop(i)=avg;
    end
end
% figure
subplot(2,2,3)
hold on
plot(years,fix_fin_pop,'r-')
plot(years,finland_population,'b-')
pop_plot('Korjattu data')
    
%fminsearch sovitus
% f = @(x,a) a(1)+a(2)*sin(x)+a(3)*x.^2;
% a0 = rand(1,3);
% sum_fun = @(a) sum((finland_population-f(years,a)).^2);
% opt = fminsearch(sum_fun,a0)

p = polyfit(years,finland_population,3)
yd = polyval(p,years);

% figure
subplot(2,2,4)
hold on
plot(years,finland_population,'k-')
plot(years,yd,'r--')
pop_plot('Sovitettu käyrä')


%% Aikasarja analyysi Suomen populaatiolle

N = length(finland_population)
%Muuttujien määrä

%Kokeillaan ennustaa viimeistä kolmea vuotta
finpop = finland_population(1:end-3)' %Kaikki paitsi viimeiset kolme vuotta dataa

%Piirretään kuva Suomen populaatiosta
figure(1)
hold on
plot(years,finland_population,'b-')
plot(years(1:end-3),finpop,'r-')
pop_plot('Suomen populaatio')
%Ei havaittavissa kausittaisuutta, mutta ylöspäin nouseva trendi voisi olla

%Testataan autokorrelaatiota
figure(2)
subplot(2,1,1)
autocorr(finland_population,40)
subplot(2,1,2)
parcorr(finland_population,40)

%Kuvasta huomataan että datassa voisi olla autokorrelaatiota, sillä
%tilastollisesti merkittäviä lag arvoja on useampia autokorrelaatio
%ploteissa
figure(1)

n = length(finpop);
X = [ones(size(finpop)) [1:length(finpop)]'];

b= X\finpop ;%Sovituksen kertoimet
Yfit = X*b; %Sovitus

%Katsotaan trendin tilastollista merkitystä
p = length(b); %parametrien määrä
res = finpop-Yfit; %residuaalit
rss = sum(res.^2); %residuaali neliöity summa
s2 = rss/(n-p);%kovarianssi
cb = inv(X'*X)*s2;
sb = sqrt(diag(cb));
tb = b./sb;
pb = 2-2*tcdf(abs(tb),n-p); %p-arvo

tss = sum((Yfit-mean(finpop)).^2);
R2 = 1- rss/tss;

SSR = sum((Yfit-mean(finpop)).^2);
SSE = rss;

F  = (SSR/(p-1))/(rss/(n-p));

est = [b tb pb];
%Saadaan hyvin suuri R arvo ja pieni p:n arvo, eli voidaan sanoa että
%trendi on tilastollisesti merkitsevä tässä tapauksesa.

%Poistetaan trendi 
detrendedY = finpop-Yfit;

%Plotataan detrendattu data
hold on
plot(years(1:end-3),detrendedY,'g-')

%Kausittaisuutta ei ole.

%Testataan stationaarisuus
h = kpsstest(detrendedY);
%On havaittavissa stationaarisuutta

Id = diff(detrendedY);

hd = kpsstest(Id);

%Tarkastetaan tämän autokorrelaatio vielä
figure(3)
subplot(2,1,1)
autocorr(Id,40)
subplot(2,1,2)
parcorr(Id,40)
%Arvoja 0-5 Lagin välillä, on tilastollisesti merkitseviä

%Tehdään arma-sovitus
%Käydään eri arma parametrien kombinaatiot läpi, ja etsitään paras
Models = []
for i = 0:1:4
    for j = 0:1:5
        M = armax(Id,[i,j]);
        a = aic(M) ; %Information criteria for fit
        Models = [Models;i j a] ;%Tallennetaan tähän kaikki eri saadut mallit
    end
end

m = find(Models(:,end) == min(Models(:,end)));
mB = Models(m,:)
ar = mB(1);
ma = mB(2);

ModelFit = armax(Id,[ar ma]);
figure(4)
%Tehdään ennustus 3v "tulevaisuuteen"
hold on
Idf = forecast(ModelFit,Id,3);

If(1) = Id(end) + Idf(1);
for i = 2:3
   If(i) = If(i-1)+Idf(i); 
end


Xf = [ones(3,1) [length(finpop)+1:length(finpop)+3]'];
Tf = Xf*b;
Forecast = Tf + If;

plot(years(end-3):1:years(end),[finpop(end) Forecast'],'r-')

%Plotataan myös todellinen data
plot(years,finland_population,'b-')
pop_plot('Populaation ennustaminen')
legend('Ennustettu data','Todellinen data')

%Ero todellisiin arvoihin:
forecast_differences = abs(Forecast-finpop(end-2:1:end))
mean_fd = mean(forecast_differences2)

%% Aikasarja analyysi poistetulle datalle

N = length(finland_population)
%Muuttujien määrä

%Kokeillaan ennustaa viimeistä kolmea vuotta poistetulle datalle
finpop = fix_fin_pop(1:end-3)' %Kaikki paitsi viimeiset kolme vuotta dataa

%Piirretään kuva Suomen populaatiosta
figure(1)
hold on
plot(years,finland_population,'b-')
plot(years(1:end-3),finpop,'r-')
pop_plot('Suomen populaatio')
%Ei havaittavissa kausittaisuutta, mutta ylöspäin nouseva trendi voisi olla

%Testataan autokorrelaatiota
figure(2)
subplot(2,1,1)
autocorr(finpop,10)
subplot(2,1,2)
parcorr(finpop,10)

%Kuvasta huomataan että datassa voisi olla autokorrelaatiota, sillä
%tilastollisesti merkittäviä lag arvoja on useampia autokorrelaatio
%ploteissa
figure(1)

n = length(finpop);
X = [ones(size(finpop)) [1:length(finpop)]'];

b= X\finpop ;%Sovituksen kertoimet
Yfit = X*b; %Sovitus

%Katsotaan trendin tilastollista merkitystä
p = length(b); %parametrien määrä
res = finpop-Yfit; %residuaalit
rss = sum(res.^2); %residuaali neliöity summa
s2 = rss/(n-p);%kovarianssi
cb = inv(X'*X)*s2
sb = sqrt(diag(cb));
tb = b./sb;
pb = 2-2*tcdf(abs(tb),n-p) ;%p-arvo

tss = sum((Yfit-mean(finpop)).^2);
R2 = 1- rss/tss;

SSR = sum((Yfit-mean(finpop)).^2);
SSE = rss;;

F  = (SSR/(p-1))/(rss/(n-p));

est = [b tb pb];
%Saadaan hyvin suuri R arvo ja pieni p:n arvo, eli voidaan sanoa että
%trendi on tilastollisesti merkitsevä tässä tapauksesa.

%Poistetaan trendi 
detrendedY = finpop-Yfit;

%Plotataan detrendattu data
hold on
plot(years(1:end-3),detrendedY,'g-')

%Kausittaisuutta ei ole.

%Testataan stationaarisuus
h = kpsstest(detrendedY);
%On havaittavissa stationaarisuutta

Id = diff(detrendedY);

hd = kpsstest(Id);

%Tarkastetaan tämän autokorrelaatio vielä
figure(3)
subplot(2,1,1)
autocorr(Id,10)
subplot(2,1,2)
parcorr(Id,10)
%Arvoja 0-5 Lagin välillä, on tilastollisesti merkitseviä

%Tehdään arma-sovitus
%Käydään eri arma parametrien kombinaatiot läpi, ja etsitään paras
Models = []
for i = 0:1:5
    for j = 0:1:5
        M = armax(Id,[i,j]);
        a = aic(M) ; %Information criteria for fit
        Models = [Models;i j a] ;%Tallennetaan tähän kaikki eri saadut mallit
    end
end

m = find(Models(:,end) == min(Models(:,end)));
mB = Models(m,:);
ar = mB(1);
ma = mB(2);

ModelFit = armax(Id,[ar ma]);
figure(4)
%Tehdään ennustus 3v "tulevaisuuteen"
hold on
Idf = forecast(ModelFit,Id,3);

If(1) = Id(end) + Idf(1);
for i = 2:3
   If(i) = If(i-1)+Idf(i); 
end


Xf = [ones(3,1) [length(finpop)+1:length(finpop)+3]'];
Tf = Xf*b;
Forecast = Tf + If;

plot(years(end-3):1:years(end),[finpop(end) Forecast'],'r-')

%Plotataan myös todellinen data
plot(years,finland_population,'b-')
pop_plot('Populaation ennustaminen')
legend('Ennustettu data','Todellinen data')


%Ero todellisiin arvoihin:
forecast_differences2 = abs(Forecast-finpop(end-2:1:end))
mean_fd2 = mean(forecast_differences2)

%% Yritetään löytää korrelaatiota yksittäisen maan ja koko alueen populaation välille.

awp = data(2403,:)'
sdp = data(208931,:)'

figure
hold on
plot(years,awp,'k-')
plot(years,sdp,'r-')
corr(awp,sdp)

figure
plot(awp,sdp)

plot(awp, sdp,'ro')


figure
%Poistetaan satunnaisesti arvoja Pohjois-Sudanin datasetistä 10 vuotta
randpop = randi([1, length(years)],1,10);
del_sdp = sdp;
del_sdp(randpop) = nan;

%Luodaan yksinkertainen selittävä malli Pohjois-Sudanin ja Arabi maailman
%välille
noNanValues = ~isnan(del_sdp)
[p, ErrorEst] = polyfit(awp(noNanValues),del_sdp(noNanValues),15)
pop_fit = polyval(p,awp, ErrorEst)
%Piirretään poistettu data
%havainnollistamaan
plot(years,del_sdp,'r-')

%Paikataan puuttuvia arvoja mallin avulla saaduilla arvoilla
fix_sdp = del_sdp
fix_sdp(randpop) = pop_fit(randpop)
%Piirretään korjattu data ja alkuperäinen data saamaan kuvaan
hold on
plot(years,sdp,'k-')
plot(years,fix_sdp,'r-')

%Ero alkuperäiseen dataan
differences = abs(sdp-fix_sdp)
mean(differences)


    
%% Plot funktio populaatiolle
function [] = pop_plot(title_text)
    hold on
    xlabel('Vuodet')
    ylabel('Populaation määrä')
    legend('Populaation kuvaaja')
    title(title_text)
    set(gca,'XAxisLocation','origin','YAxisLocation','origin')
end

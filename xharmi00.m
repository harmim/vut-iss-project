% Author: Dominik Harmim <xharmi00@stud.fit.vutbr.cz>

% 1) Naètìte Váš osobní signál ze souboru xharmi00.wav.
% Napište vzorkovací frekvenci signálu a jeho délku ve
% vzorcích a v sekundách.
fprintf('1)\n');
[signal, fs] = audioread('xharmi00.wav');
signal = signal'; % potrebujeme radkovy vektor
samples_length = length(signal);
fprintf('Vzorkovací frekvence signálu: %f [Hz].\n', fs);
fprintf('Délka signálu ve vzorcích: %f, v sekundách: %f [s].\n', samples_length, samples_length / fs);


% 2) Vypoèítejte spektrum signálu pomocí diskrétní Fourierovy
% transformace. Do protokolu vložte obrázek modulu spektra v
% závislosti na frekvenci. Frekvenèní osa musí být v Hz a pouze od 0
% do poloviny vzorkovací frekvence.
fprintf('\n2)\n');
frequency = (0 : samples_length / 2 - 1) / samples_length * fs;
fft_signal = abs(fft(signal));
fft_signal = fft_signal(1 : samples_length / 2);
f = figure('Visible', 'off');
plot(frequency, fft_signal);
xlabel('f [Hz]');
legend('Modul spektra signálu');
grid;
print(f, '-depsc', 'inc/2.eps');
close(f);


% 3) Urèete a napište, na které frekvenci v Hz je maximum modulu spektra.
fprintf('\n3)\n');
[~, max_index] = max(fft_signal);
fprintf('Maximum modulu spektra signálu je na frekvenci %f [Hz].\n', frequency(max_index));


% 4) Pro další zpracování je dán IIR filtr s následujícími koeficienty:
% b0 = 0.2324, b1 = -0.4112, b2 = 0.2324, a1 = 0.2289, a2 = 0.4662
% Do protokolu vložte obrázek s nulami a póly pøenosové funkce
% tohoto filtru a uveïte, zda je filtr stabilní.
fprintf('\n4)\n');
b = [0.2324 -0.4112 0.2324];
a = [1 0.2289 0.4662];
if abs(roots(a)) < 1
	fprintf('Filtr je stabilní.\n');
else
	fprintf('Filtr není stabilní.\n');
end
f = figure('Visible', 'off');
zplane(b, a);
xlabel('Reálná èást');
ylabel('Imaginární èást');
print(f, '-depsc', 'inc/4.eps');
close(f);


% 5) Do protokolu vložte obrázek s modulem kmitoètové charakteristiky
% tohoto filtru (frekvenèní osa musí být v Hz a pouze od 0
% do poloviny vzorkovací frekvence) a uveïte, jakého je filtr typu
% (dolní propus / horní propus / pásmová propus / pásmová zádrž).
fprintf('\n5)\n');
f = figure('Visible', 'off');
plot((0 : 255) / 256 * fs / 2, abs(freqz(b, a, 256)));
xlabel('f [Hz]');
ylabel('|H(f)|');
legend('Modul kmitoètové charakteristiky');
grid;
print(f, '-depsc', 'inc/5.eps');
close(f);


% 6) Filtrujte naètený signál tímto filtrem. Z výsledného signálu
% vypoèítejte spektrum signálu pomocí diskrétní Fourierovy
% transformace. Do protokolu vložte obrázek modulu spektra v
% závislosti na frekvenci. Frekvenèní osa musí být v Hz a pouze od 0
% do poloviny vzorkovací frekvence.
fprintf('\n6)\n');
fft_filtered_signal = abs(fft(filter(b, a, signal)));
fft_filtered_signal = fft_filtered_signal(1 : samples_length / 2);
f = figure('Visible', 'off');
plot(frequency, fft_filtered_signal);
xlabel('f [Hz]');
legend('Modul spektra filtrovaného signálu');
grid;
print(f, '-depsc', 'inc/6.eps');
close(f);


% 7) Urèete a napište, na které frekvenci v Hz je maximum modulu
% spektra filtrovaného signálu.
fprintf('\n7)\n');
[~, max_filtered_index] = max(fft_filtered_signal);
fprintf('Maximum modulu spektra filtrovaného signálu je na frekvenci %f [Hz].\n', frequency(max_filtered_index));


% 8) V tomto a dalším cvièeních budete pracovat s pùvodním signálem, ne s filtrovaným.
% Do signálu bylo pøimícháno 20 ms obdélníkových impulsù se støední hodnotou
% nula a støídou 50 % na frekvenci 4 kHz. Tedy 80 sekvencí [h h -h -h] (kde h je kladné èíslo) za sebou.
% Najdìte, kde jsou - napište èas ve vzorcích a v sekundách.
% Pomùcka: pokud netušíte, jak na to, uvažte napø. pøizpùsobený filtr,
% výrobu spektra této sekvence a jeho hledání ve spektru signálu
% rozdìleného po 20ti ms, poslech, atd. Cílem není matematická èistota,
% ale vyøešení úkolu.
fprintf('\n8)\n');
number_of_samples = 80 * 4;
s = 0;
max_index = samples_length - number_of_samples;
range = 1 : max_index;
mat = range;
for i = range
	for j = 1 : number_of_samples
		switch j - floor(j / 4) * 4
			case {0, 1}
				c = 1;
			case {2, 3}
				c = -1;
			otherwise
				c = 0;
		end
		s = signal(i - 1 + j) * c + s;
	end
	mat(i) = s;
	s = 0;
end
f = figure('Visible', 'off');
plot(mat);
grid;
print(f, '-depsc', 'inc/8.eps');
close(f);
[~, max_rec_pulses_index] = max(mat);
fprintf('Obedlníkové implusy se nacházejí na vzorku %f, v èase %f [s].\n', max_rec_pulses_index, max_rec_pulses_index / fs);


% 9) Spoèítejte a do protokolu vložte obrázek autokorelaèních
% koeficientù R[k] pro k náleží -50...50. Použijte vychýlený
% odhad koeficientù podle vztahu R[k] = 1/N*Suma(x[n]*x[n+k])
fprintf('\n9)\n');
k = (-50 : 50);
R = xcorr(signal) / samples_length;
R = R(k + samples_length);
f = figure('Visible', 'off');
plot(k, R);
xlabel('k');
legend('Autokorelaèní koeficient');
grid;
print(f, '-depsc', 'inc/9.eps');
close(f);


% 10) Napište hodnotu koeficientu R[10].
fprintf('\n10)\n');
fprintf('Hodnota koeficientu R[10] je %f.\n', R(61));


% 11) Proveïte èasový odhad sdružené funkce hustoty rozdìlení
% pravdìpodobnosti p(x1, x2, 10) mezi vzorky n a n+10. Do
% protokolu vložte
% 3-D obrázek tìchto hodnot. Mùžete použít barevnou mapu, odstíny
% šedi, projekci 3D do 2D, jak chcete. Chcete-li, mùžete pro toto a
% následující dvì cvièení využít
% nebo vykuchat dodanou funkci hist2opt.m. Funkce ovšem øeší
% souborový odhad, pro zadaný èasový odhad ji musíte modifikovat nebo
% šikovnì zavolat.
fprintf('\n11)\n');
N = length(signal);
L = 50;
x = linspace(min(signal), max(signal), 50);
h = zeros(L, L);
[~, ind1] = min(abs(repmat(signal(:)', L, 1) - repmat(x(:), 1, N)));
ind2 = ind1(10 + 1 : N);
for i = 1 : N - 10,
	d1 = ind1(i);
	d2 = ind2(i);
	h(d1, d2) = h(d1, d2) + 1;
end
surf = (x(2) - x(1)) ^ 2;
p = h / N / surf;
f = figure('Visible', 'off');
imagesc(x, x, p);
axis xy;
colorbar;
xlabel('x2');
ylabel('x1');
print(f, '-depsc', 'inc/11.eps');
close(f);


% 12) Ovìøte, že se jedná o správnou sdruženou funkci hustoty rozdìlení
% pravdìpodobnosti, tedy že integral{x1} integral{x2} p(x1, x2, 10) dx1 dx2 = 1
fprintf('\n12)\n');
check = sum(sum(p)) * surf;
fprintf('Ovìøení, že se jedná o správnou sdruženou funkci hustoty rozdìlení pravdìpodobnosti, 2D integrál by mìl být roven 1 a je roven %f.\n', check);


% 13) Vypoètìte z této odhadnuté funkce hustoty rozdìlení
% pravdìpodobnosti autokorelaèní koeficient R[10]:
% R[10] = integral{x1} integral{x2} x1 x2 p(x1, x2, 10) dx1 dx2
% Srovnejte s hodnotou vypoèítanou v pøíkladu 10 a komentujte výsledek.
fprintf('\n13)\n');
fprintf('Hodnota koeficientu R[10] je %f.\n', sum(sum(repmat(x(:), 1, L) .* repmat(x(:)', L, 1) .* p)) * surf);

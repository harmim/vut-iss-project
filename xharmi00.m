% Author: Dominik Harmim <xharmi00@stud.fit.vutbr.cz>

% 1) Na�t�te V� osobn� sign�l ze souboru xharmi00.wav.
% Napi�te vzorkovac� frekvenci sign�lu a jeho d�lku ve
% vzorc�ch a v sekund�ch.
fprintf('1)\n');
[signal, fs] = audioread('xharmi00.wav');
signal = signal'; % potrebujeme radkovy vektor
samples_length = length(signal);
fprintf('Vzorkovac� frekvence sign�lu: %f [Hz].\n', fs);
fprintf('D�lka sign�lu ve vzorc�ch: %f, v sekund�ch: %f [s].\n', samples_length, samples_length / fs);


% 2) Vypo��tejte spektrum sign�lu pomoc� diskr�tn� Fourierovy
% transformace. Do protokolu vlo�te obr�zek modulu spektra v
% z�vislosti na frekvenci. Frekven�n� osa mus� b�t v Hz a pouze od 0
% do poloviny vzorkovac� frekvence.
fprintf('\n2)\n');
frequency = (0 : samples_length / 2 - 1) / samples_length * fs;
fft_signal = abs(fft(signal));
fft_signal = fft_signal(1 : samples_length / 2);
f = figure('Visible', 'off');
plot(frequency, fft_signal);
xlabel('f [Hz]');
legend('Modul spektra sign�lu');
grid;
print(f, '-depsc', 'inc/2.eps');
close(f);


% 3) Ur�ete a napi�te, na kter� frekvenci v Hz je maximum modulu spektra.
fprintf('\n3)\n');
[~, max_index] = max(fft_signal);
fprintf('Maximum modulu spektra sign�lu je na frekvenci %f [Hz].\n', frequency(max_index));


% 4) Pro dal�� zpracov�n� je d�n IIR filtr s n�sleduj�c�mi koeficienty:
% b0 = 0.2324, b1 = -0.4112, b2 = 0.2324, a1 = 0.2289, a2 = 0.4662
% Do protokolu vlo�te obr�zek s nulami a p�ly p�enosov� funkce
% tohoto filtru a uve�te, zda je filtr stabiln�.
fprintf('\n4)\n');
b = [0.2324 -0.4112 0.2324];
a = [1 0.2289 0.4662];
if abs(roots(a)) < 1
	fprintf('Filtr je stabiln�.\n');
else
	fprintf('Filtr nen� stabiln�.\n');
end
f = figure('Visible', 'off');
zplane(b, a);
xlabel('Re�ln� ��st');
ylabel('Imagin�rn� ��st');
print(f, '-depsc', 'inc/4.eps');
close(f);


% 5) Do protokolu vlo�te obr�zek s modulem kmito�tov� charakteristiky
% tohoto filtru (frekven�n� osa mus� b�t v Hz a pouze od 0
% do poloviny vzorkovac� frekvence) a uve�te, jak�ho je filtr typu
% (doln� propus� / horn� propus� / p�smov� propus� / p�smov� z�dr�).
fprintf('\n5)\n');
f = figure('Visible', 'off');
plot((0 : 255) / 256 * fs / 2, abs(freqz(b, a, 256)));
xlabel('f [Hz]');
ylabel('|H(f)|');
legend('Modul kmito�tov� charakteristiky');
grid;
print(f, '-depsc', 'inc/5.eps');
close(f);


% 6) Filtrujte na�ten� sign�l t�mto filtrem. Z v�sledn�ho sign�lu
% vypo��tejte spektrum sign�lu pomoc� diskr�tn� Fourierovy
% transformace. Do protokolu vlo�te obr�zek modulu spektra v
% z�vislosti na frekvenci. Frekven�n� osa mus� b�t v Hz a pouze od 0
% do poloviny vzorkovac� frekvence.
fprintf('\n6)\n');
fft_filtered_signal = abs(fft(filter(b, a, signal)));
fft_filtered_signal = fft_filtered_signal(1 : samples_length / 2);
f = figure('Visible', 'off');
plot(frequency, fft_filtered_signal);
xlabel('f [Hz]');
legend('Modul spektra filtrovan�ho sign�lu');
grid;
print(f, '-depsc', 'inc/6.eps');
close(f);


% 7) Ur�ete a napi�te, na kter� frekvenci v Hz je maximum modulu
% spektra filtrovan�ho sign�lu.
fprintf('\n7)\n');
[~, max_filtered_index] = max(fft_filtered_signal);
fprintf('Maximum modulu spektra filtrovan�ho sign�lu je na frekvenci %f [Hz].\n', frequency(max_filtered_index));


% 8) V tomto a dal��m cvi�en�ch budete pracovat s p�vodn�m sign�lem, ne s filtrovan�m.
% Do sign�lu bylo p�im�ch�no 20 ms obd�ln�kov�ch impuls� se st�edn� hodnotou
% nula a st��dou 50 % na frekvenci 4 kHz. Tedy 80 sekvenc� [h h -h -h] (kde h je kladn� ��slo) za sebou.
% Najd�te, kde jsou - napi�te �as ve vzorc�ch a v sekund�ch.
% Pom�cka: pokud netu��te, jak na to, uva�te nap�. p�izp�soben� filtr,
% v�robu spektra t�to sekvence a jeho hled�n� ve spektru sign�lu
% rozd�len�ho po 20ti ms, poslech, atd. C�lem nen� matematick� �istota,
% ale vy�e�en� �kolu.
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
fprintf('Obedln�kov� implusy se nach�zej� na vzorku %f, v �ase %f [s].\n', max_rec_pulses_index, max_rec_pulses_index / fs);


% 9) Spo��tejte a do protokolu vlo�te obr�zek autokorela�n�ch
% koeficient� R[k] pro k n�le�� -50...50. Pou�ijte vych�len�
% odhad koeficient� podle vztahu R[k] = 1/N*Suma(x[n]*x[n+k])
fprintf('\n9)\n');
k = (-50 : 50);
R = xcorr(signal) / samples_length;
R = R(k + samples_length);
f = figure('Visible', 'off');
plot(k, R);
xlabel('k');
legend('Autokorela�n� koeficient');
grid;
print(f, '-depsc', 'inc/9.eps');
close(f);


% 10) Napi�te hodnotu koeficientu R[10].
fprintf('\n10)\n');
fprintf('Hodnota koeficientu R[10] je %f.\n', R(61));


% 11) Prove�te �asov� odhad sdru�en� funkce hustoty rozd�len�
% pravd�podobnosti p(x1, x2, 10) mezi vzorky n a n+10. Do
% protokolu vlo�te
% 3-D obr�zek t�chto hodnot. M��ete pou��t barevnou mapu, odst�ny
% �edi, projekci 3D do 2D, jak chcete. Chcete-li, m��ete pro toto a
% n�sleduj�c� dv� cvi�en� vyu��t
% nebo vykuchat dodanou funkci hist2opt.m. Funkce ov�em �e��
% souborov� odhad, pro zadan� �asov� odhad ji mus�te modifikovat nebo
% �ikovn� zavolat.
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


% 12) Ov��te, �e se jedn� o spr�vnou sdru�enou funkci hustoty rozd�len�
% pravd�podobnosti, tedy �e integral{x1} integral{x2} p(x1, x2, 10) dx1 dx2 = 1
fprintf('\n12)\n');
check = sum(sum(p)) * surf;
fprintf('Ov��en�, �e se jedn� o spr�vnou sdru�enou funkci hustoty rozd�len� pravd�podobnosti, 2D integr�l by m�l b�t roven 1 a je roven %f.\n', check);


% 13) Vypo�t�te z t�to odhadnut� funkce hustoty rozd�len�
% pravd�podobnosti autokorela�n� koeficient R[10]:
% R[10] = integral{x1} integral{x2} x1 x2 p(x1, x2, 10) dx1 dx2
% Srovnejte s hodnotou vypo��tanou v p��kladu 10 a komentujte v�sledek.
fprintf('\n13)\n');
fprintf('Hodnota koeficientu R[10] je %f.\n', sum(sum(repmat(x(:), 1, L) .* repmat(x(:)', L, 1) .* p)) * surf);

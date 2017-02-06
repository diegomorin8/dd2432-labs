%% Artificial Neural Networks and other Learning Systems - Lab 2

%%
set(0, 'DefaultFigurePosition', get(0,'screensize'));
addpath('info');

%% 1. Introduction
%
% In this lab we use Radial Basis Functions (RBF) to approximate some simple 
% functions of one variable. Suppose we have the function $f: R 
% \to R$. RBF introduces a hidden layer such that $\hat{f}: 
% R \to R^n \to R$, where $n$ is the number of 
% neurons in the hidden layer. The trick basically consists on mapping an 
% input $x \in R$ to a new space $R^n$ using a set of 
% functions $\{\phi_i\}_{i=1}^n$ and then back to ${R}$. 
% The functions used are Gaussians with different means and, possibly, also 
% different variances
% 
% $$
% \phi_i(x) = \frac{\exp \Big(-\frac{(x-\mu_i)^2}{2\sigma_i}\Big)}{\sum_i 
% \exp \Big(-\frac{(x-\mu_i)^2}{2\sigma_i}\Big)}.
% $$
%
% _Radial_ comes from the fact that the functions $\{\phi_i\}_{i=1}^n$ 
% operate on distances rather than on the input points themselves. In this 
% regard, the selection of $\{\mu_i\}_{i=1}^n$ is essential and is typically 
% done using K-means or by simply selecting some points from the training set. 
% Given an input $x$ the output of the network is
%
% $$
% \hat{f}(x) = \sum_{i=1}^n w_i \phi_i(x).
% $$
%
% Thus we can say that the units in the hidden layer work as _basis_
% in which the function $\hat{f}$ can be expressed. 
% The motivation behind this technique is the fact that in higher 
% dimensional spaces, data is usually linearly separable. 
% Suppose we have a set of patterns $\{x_1, \dots, x_N\}$ and their 
% corresponding real function values $\{f_1, \dots, f_N\}$. While training, 
% the neural network minimizes the error measure
%
% $$
% total~error = \sum_{k=1}^N (\hat{f}_k-f_k)^2.
% $$
%
% <html><h3>Computing the weight matrix</h3></html>
%
% The weights of the network are found by solving the following system 
%
% $$\phi_1(x_1)w_1 + \phi_2(x_1)w_2 + \dots + \phi_n(x_1)w_n = f_1 $$
% 
% $$\phi_1(x_2)w_1 + \phi_2(x_2)w_2 + \dots + \phi_n(x_2)w_n = f_2 $$
%
% ...
%
% $$\phi_1(x_k)w_1 + \phi_2(x_k)w_2 + \dots + \phi_n(x_k)w_n = f_k $$
%
% ...
%
% $$\phi_1(x_N)w_1 + \phi_2(x_N)w_2 + \dots + \phi_n(x_N)w_n = f_N$$
%
% _*Question*_ What is the lower bound for the number of training examples, $N$?
% 
% From basic linear algebra, we need at least $n$ equations in a system with $n$ variables. Otherwise, the system is underdefined. Hence, we have that $N\geq n$. If the number of samples is smaller than the number of hidden units, some units will end up doing nothing or doing the same thing as other units (i.e. will activate around the same point in the input space)
% 
% _*Question*_ What happens with the error if $N=n$? Why?
% 
% If this is the case, and the system is full-rank, we have that we can find a set of weights $\{w_i\}_{i=0}^n$ such that we perfectly reconstruct the target function, i.e. $\hat{f}_k = f_k$ for all the training samples. Thus we can decrease the error to zero.
% From the network perspective what will happen is that every RBF unit will "specialize" in one single training point. For this reason, every time we feed an input there will be only one unit active and the others will be off, making it trivial for the following layer to classify the point. However, this is not a desirable behavior, because the network will have overfitted on the training points and will underperform on unseen data.
% 
% _*Question*_ Under what conditions, if any, does (\ref{eq:1}) have a solution in this case?
% 
% This happens if the rank per columns and the rank per rows is the same.
% 
% _*Question*_ During training we use an error measure defined over the training examples. Is it good to use this measure when evaluating the performance of the network? Explain!
% Although we can make the error zero on the training set, it does not mean that the network will perform well with unseen data. On the contrary, we risk to overfit the network and reduce its generalization power.
%
% <html><h3>Least Squares</h3></html>
%
% Now our error measure becomes $total~error = ||?{\Phi}{w} - \textbf{f}||^2$, which is minimized by solving $?{\Phi}^T?{\Phi}\textbf{w} = {\Phi} \textbf{f}$, i.e.
% 
% $$
% \textbf{w}_{opt} = ({\Phi}^T?{\Phi})^{-1}{\Phi}^T?\textbf{f}.
% $$
%
% <html><h3>The Delta Rule</h3></html>
%
% Sometimes, not all the sample patterns are accessible simultaneously.  If the network operates on a continuous stream of data,  the process of computing the weights changes from the previous case. We now define our error using the expectation
% 
% $$
% \xi = expected~error= \textbf{E}\Big[ 1/2 (f(x) - \hat{f}(x))^2\Big].
% $$
% 
% However, since we cannot find an exact expression for $\xi$ we use the instantaneous error as an estimate of $\xi$, i.e.
%
% $$
% \xi \approx \hat{\xi} = \frac{1}{2} (f(x) - \hat{f}(x))^2 = \frac{1}{2} e^2.
% $$
%
% Our goal here is to make $\hat{\xi} \to 0$ as fast as possible. To do so, we take a step $\Delta \textbf{w}$ in the opposite direction of the gradent of the error surface, i.e.
% 
% $$\Delta \textbf{w} = -\eta \nabla_\textbf{w} \hat{\xi} $$
%
% $$ ~= -\eta \frac{1}{2}\nabla_\textbf{w}(f(x_k)-{\Phi}(x_k)\textbf{w})^2 $$
%
% $$ ~= \eta(f(x_k)-{\Phi}(x_k)^T\textbf{w}){\Phi}(x_k) $$
%
% $$ ~= \eta e {\Phi}(x_k) $$
%
%% 4.1 Supervised Learning of Network Weights (Batch mode training using least squares
%
%%
% <html><h3>Using a sinus function</h3></html>
%
% Let us consider the following function $f(x)=\sin(2x)\ x\in[0,2\pi]$,
% where
%
% * Number of samples N
% * Number of units n

% Initialization
x = (0:0.1:2*pi)';
N = size(x, 1);
f = sin(2*x);

plot_these =  [4, 5, 6, 7, 25, 56, 60];
all_residuals = [];
for units = 1:60
    makerbf;

    % Compute RBF for every input
    Phi = calcPhi(x, m, sigma2);

    % Compute least square solution for the batch
    w = Phi\f;

    % Network output
    y = Phi*w;

    if sum(units==plot_these)==1
        figure;
        rbfplot1(x, y, f, units, m, sigma2, w)
    end
    all_residuals = [all_residuals, max(abs(f-y))];
    
end

figure;
plot(1:60, all_residuals);
title('Residual error depending on number of hidden RBF units','Interpreter', 'latex','FontSize',16);
xlabel('Number of hidden RBF units','Interpreter', 'latex','FontSize',16);
ylabel('Residual error','Interpreter', 'latex','FontSize',16)
grid on;

%%
% _*Question 1*_
% We get a residual of:
%
% * 1.1238 with 5 units
% * 0.1328 with 6 units
% * <0.1 with 7 units
% * <0.01 with 25 units
% * <0.001 with 56 units
%
% _*Question 2*_
%
% With 5 units we get a very high residual, with 6 units we get a
% surprisingly lower residual. Observing the plots of the RBF activations
% weighted by their weigths we notice that every time an RBF has its mean
% in correspondence to a zero in the output, its weight is pulled towards
% 0. (observe the plots with 4, 5 and 6 units)
%
% This can be explained by considering that the second has the purpose
% of "mimiking" the original function: if an RBF unit activates in proximity
% to a zero of the function, the layer must lower the corresponding weight
% to get a low output.
% 
% In the 5 unit example we can see how all 5 units end up close to the 
% zeros of $sin(2x)$ and that their associated weights are close to zero.
% This means that for every other input the output of the network will be
% close to zero and will not be able to approximate the original function.
%
% Also note how this happens every time for any number of units, at least 
% for the units placed in $0$ and $2\pi$. However if there are othe units
% that are not affected by this problem, the network performs correctly.
%

%%
% <html><h3>Using a square function</h3></html>
%
% Now we consider the function $f(x)=square(2x)\ x\in[0,2\pi]$, where
%
% # Number of samples N
% # Number of units n
%

% Initialization
x = (0:0.1:2*pi)';
N = size(x, 1);
f = square(2*x);

plot_these =  [4, 5, 6, 7, 25, 56, 60];
all_residuals = [];
for units = 1:100
    %makerbf;

    % Compute RBF for every input
    Phi = calcPhi(x, m, sigma2);

    % Compute least square solution for the batch
    w = Phi\f;

    % Network output
    y = Phi*w;

    if sum(units==plot_these)==1
        figure;
        rbfplot1(x, y, f, units, m, sigma2, w)
    end
    all_residuals = [all_residuals, max(abs(f-y))];
    
end

figure;
plot(1:100, all_residuals);
title('Residual error depending on number of hidden RBF units','Interpreter', 'latex','FontSize',16);
xlabel('Number of hidden RBF units','Interpreter', 'latex','FontSize',16);
ylabel('Residual error','Interpreter', 'latex','FontSize',16)
grid on;

%% 
% _*Question 3*_
%
% We get:
% # Less than 0.1 with more than 62 RBF units
% # $\approx 0$ with more than 63 RBF units
%
% _*Question 4*_
%
% It can be considered as a binary classification problem, where the
% classification to ba made could be for instance $sign(\sin (2x))$.
% 
% _*Question 5*_
%
% We've seen before that we're able to approximate $\sin (2x)$ with 6
% units. Given that this second problem can be regarded as approximating 
% $sign(\sin (2x))$, we can get a perfect result just by applying a
% threshold to the output of the previous network.
%
% We've checked it by plotting $sign(y)$ with 6 units.
%
% _*Question 6*_ XOR problem with RBF networks
%
% Consider the XOR problem in this form
% 
% <html>
% <table border=1><tr><td>x1</td><td>x2</td><td>y</td></tr>
% <tr><td>0</td><td>0</td><td>0</td></tr>
% <tr><td>0</td><td>1</td><td>1</td></tr>
% <tr><td>1</td><td>0</td><td>1</td></tr>
% <tr><td>1</td><td>1</td><td>0</td></tr></table>
% </html>
%
% We can now imagine a network with 2 inputs, 4 hidden RBF units and 1
% output. We can give each of the RBF unit a mean that matches one of the
% four inputs. In this way, for every input we will have a single RBF unit
% that is highly active and the remaining will be close to zero (given that
% we choose a suitable variance). The final layer will simply need to learn
% to assign a high weight to the two units corresponding to the sencond and
% third row of the table and a low weight to the other two. We can now
% observe how we can actually get rid of the two neurons that map the
% first and last row of the table, because the sum of the activations
% performed in the last layer will be close to zero anyway. Hence the XOR
% problem can be soved by an RBF network with 2 hidden units.

% TODO write something else about XOR

%% 4.2 On-line training using the delta rule
% _*Question 7*_
% See table for results:

clear;
rng(123);

x = (0:0.1:2*pi)';
N = size(x, 1);
fun = 'sin2x';

column_rbf = [];
column_iters = [];
column_eta = [];
column_max = [];
column_avg = [];

fun = 'sin2x';
for units = [6, 10, 40]
    for eta_pair = [[.5, .1]; [1, .8]; [2, .8]; [2,1]; [3, .8]; [4,.8]]'
        makerbf;

        totalIter = 4000;

        figure;
        iter = 0;
        itersub = 20;
        itermax = 2020;
        eta = eta_pair(1);
        color = 'r';
        diter;

        column_rbf = [column_rbf, units];
        column_iters = [column_iters, 2000];
        column_eta = [column_eta, eta];
        column_max = [column_max, max_abs];
        column_avg = [column_avg, max_mean];

        iter = 2000;
        itersub = 20;
        itermax = 2000;
        eta = eta_pair(2);
        color = 'b';
        diter;

        column_rbf = [column_rbf, units];
        column_iters = [column_iters, 2000];
        column_eta = [column_eta, eta];
        column_max = [column_max, max_abs];
        column_avg = [column_avg, max_mean];
    end;
end;

table(column_rbf', column_iters', column_eta', column_max', column_avg' ...
    , 'VariableNames', {'RBF_units', 'Iters', 'Eta', 'Final_Max', 'Final_avg'})

%%
% _*Question 8*_
% We are using a custom function:
%
% $$y = \frac{4}{5} \sin(2x+1) \log(x+1.5)$$
%

fun = 'func';
units = 10;
eta_pair = [2, 0.8];

makerbf;

totalIter = 4000;

figure;
iter = 0;
itersub = 20;
itermax = 2020;
eta = eta_pair(1);
color = 'r';
diter;

iter = 2000;
itersub = 20;
itermax = 2000;
eta = eta_pair(2);
color = 'b';
diter;

%% 5 RBF Placement by Self Organization
% <html><h3>Competitive learning - single winner</h3></html>
clear;
plotinit;
data=read('cluster');
units=5;
vqinit;
singlewinner=1;
vqiter;

% // TODO fix drifting trajectories of the centers

%%
% <html><h3>Competitive learning - shared updates</h3></html>
clear;
plotinit;
data=read('cluster');
units=5;
vqinit;
singlewinner=0;
vqiter;

%%
% _*Question 9,10*_
% Using a single winner strategy:
%
% * *CON* Sometimes some units never get updated because at the very beginning they
% were placed in un unfortunate position, far from any datapoint.
% * *PRO* Once the fitting is complete we can check through the validation
% data whether there are units that are never highly active and delete
% them.

%% 
% <html><h3>Expectation maximization - single winner</h3></html>
%
% We see how the central big unit is "dead", meaning that it will no be
% useful for a latter clustering of the data due to the fact that its
% center is too far from any of the inputs and its spread is too high to
% have an high activation value.
clear;
rng(123);
plotinit;
data=read('cluster');
units=5;
vqinit;
singlewinner=1;
emiterb;

%%
% <html><h3>Expectation maximization - shared updates - 7 units</h3></html>
clear;
rng(12);
plotinit;
data=read('cluster');
units=7;
vqinit;
singlewinner=0;
emiterb;

%%
% <html><h3>Expectation maximization - shared updates - 30 units</h3></html>
%
% We can see how allowing the spread of the RBF units to vary yields an
% even worse overfitting because the, each input point has a corresponding RBF centered on it, 
% some of them even more than one)
clear;
rng(12);
plotinit;
data=read('cluster');
units=30;
vqinit;
singlewinner=0;
emiterb;

%% 6 Function Approximation for Noisy Data
%

% Setup
clear;
rng(3); % 3 or 4 don't lead to a big dead unit
plotinit;

% Load data
[xtrain, ytrain]=readxy('ballist',2,2);
[xtest, ytest]=readxy('balltest',2,2);

allx = [xtrain, xtest];
ally = [ytrain, ytest];
scatter3(allx(:,1), allx(:,2), ally(:,1),'.');
scatter3(allx(:,1), allx(:,2), ally(:,2)),'.';

% Use e.g. 20 units and train the unsupervised part.
data=xtrain;
units=20;
vqinit;
singlewinner=1;
emiterb

% In this case we have a two dimensional input space and a two dimensional
% output space. The two output values are coded with one unit each in the output
% layer. Here we will train the weight vectors to these units separately. Start as
% before by calculating the matrix $\phi$ of RBF responses:
Phi=calcPhi(xtrain,m,sigma2);

% Extract the two desired y vectors for train and test
d1=ytrain(:,1);
d2=ytrain(:,2);
dtest1=ytest(:,1);
dtest2=ytest(:,2);

% and calculate the weight vectors by the pseudo inverse method
w1=Phi\d1;
w2=Phi\d2;

% Now we can calculate approximations of training data
y1=Phi*w1;
y2=Phi*w2;

% as well as approximations of test data
Phitest=calcPhi(xtest,m,sigma2);
ytest1=Phitest*w1;
ytest2=Phitest*w2;

% Finally we plot these
figure;
subplot(2,2,1); xyplot(d1,y1,'train angle'); grid on; axis('image');
subplot(2,2,2); xyplot(d2,y2,'train velocity');  grid on; axis('image');
subplot(2,2,3); xyplot(dtest1,ytest1,'test angle'); grid on; axis('image');
subplot(2,2,4); xyplot(dtest2,ytest2,'test velocity');  grid on; axis('image');

x1_full= linspace(min(allx(:,1)), max(allx(:,1)), 100);
x2_full= linspace(min(allx(:,2)), max(allx(:,2)), 100);
[x1_full, x2_full] = meshgrid(x1_full, x2_full);
data = [x1_full(:), x2_full(:)];

Phifull=calcPhi(data,m,sigma2);
y1_full=Phifull*w1;
y2_full=Phifull*w2;

figure;
subplot(1,2,1);
hold on;
surf(x1_full,x2_full,reshape(y1_full,[100,100]), 'EdgeColor','none','LineStyle','none','FaceLighting','phong');
scatter3(allx(:,1), allx(:,2), ally(:,1),'.k');
colormap cool;
alpha(.2);

subplot(1,2,2);
hold on;
surf(x1_full,x2_full,reshape(y2_full,[100,100]), 'EdgeColor','none','LineStyle','none','FaceLighting','phong');
scatter3(allx(:,1), allx(:,2), ally(:,2),'.k');
colormap cool;
alpha(.2);

%% 6 Bonus - Smoothing with Gaussian kernel
% Smoothing with a Gaussian kernel:
%
% $$\tilde{y}^1_i = \sum_k e^{-\frac{||\mathbf{x}_i-\mathbf{x}_k||^2}{\sigma}}y^1_k$$
%
% $$\tilde{y}^2_i = \sum_k e^{-\frac{||\mathbf{x}_i-\mathbf{x}_k||^2}{\sigma}}y^2_k$$
%
% In matrix form:
%
% $$ K_{i,j} = e^{-\frac{||\mathbf{x}_i-\mathbf{x}_k||^2}{\sigma} $$
%
% $$\tilde{y} = K y$$
%

% Just to plot the gram matrix
K = exp(-squareform(pdist(sort(xtrain), 'squaredeuclidean')./0.05)); 
HeatMap(K);
% Actual useful gram matrix
K = exp(-squareform(pdist(xtrain, 'squaredeuclidean')./0.05));
ytrain_smooth = K*ytrain ./ [sum(K, 2), sum(K, 2)];

% Plotting just ytrain vs ytrain smoothed (dimension 1 only)
figure;
hold on;
scatter3(xtrain(:,1), xtrain(:,2), ytrain(:,1),'.b');
scatter3(xtrain(:,1), xtrain(:,2), ytrain_smooth(:,1),'.r');

% Plotting surfaces from ytrain vs ytrain smoothed (dimension 1 only)
figure;
hold on;

% non smoothed y1
x1_full= linspace(min(xtrain(:,1)), max(xtrain(:,1)), 100);
x2_full= linspace(min(xtrain(:,2)), max(xtrain(:,2)), 100);
[x1_full_mesh, x2_full_mesh] = meshgrid(x1_full, x2_full);
z_train = griddata(xtrain(:,1), xtrain(:,2), ytrain(:,1) ,x1_full_mesh, x2_full_mesh);
scatter3(xtrain(:,1),xtrain(:,2),ytrain(:,1),'.r');
surf(x1_full_mesh,x2_full_mesh,z_train, 'EdgeColor','red','FaceLighting','phong');
alpha(0.2);

% smoothed y1
x1_full= linspace(min(xtrain(:,1)), max(xtrain(:,1)), 100);
x2_full= linspace(min(xtrain(:,2)), max(xtrain(:,2)), 100);
[x1_full_mesh, x2_full_mesh] = meshgrid(x1_full, x2_full);
z_train = griddata(xtrain(:,1), xtrain(:,2), ytrain_smooth(:,1) ,x1_full_mesh, x2_full_mesh);
surf(x1_full_mesh,x2_full_mesh,z_train, 'EdgeColor','blue','FaceLighting','phong');
scatter3(xtrain(:,1),xtrain(:,2),ytrain_smooth(:,1),'.b');
alpha(0.2);

Phi=calcPhi(xtrain,m,sigma2);

% Extract the two desired y vectors for train and test
d1=ytrain_smooth(:,1);
d2=ytrain_smooth(:,2);
dtest1=ytest(:,1);
dtest2=ytest(:,2);

% and calculate the weight vectors by the pseudo inverse method
w1=Phi\d1;
w2=Phi\d2;

% Now we can calculate approximations of training data
y1=Phi*w1;
y2=Phi*w2;

% as well as approximations of test data
Phitest=calcPhi(xtest,m,sigma2);
ytest1=Phitest*w1;
ytest2=Phitest*w2;

% Finally we plot these
figure;
subplot(2,2,1); xyplot(d1,y1,'train angle'); grid on; axis('image');
subplot(2,2,2); xyplot(d2,y2,'train velocity');  grid on; axis('image');
subplot(2,2,3); xyplot(dtest1,ytest1,'test angle'); grid on; axis('image');
subplot(2,2,4); xyplot(dtest2,ytest2,'test velocity');  grid on; axis('image');

x1_full= linspace(min(allx(:,1)), max(allx(:,1)), 100);
x2_full= linspace(min(allx(:,2)), max(allx(:,2)), 100);
[x1_full, x2_full] = meshgrid(x1_full, x2_full);
data = [x1_full(:), x2_full(:)];

Phifull=calcPhi(data,m,sigma2);
y1_full=Phifull*w1;
y2_full=Phifull*w2;

figure;
subplot(1,2,1);
hold on;
surf(x1_full,x2_full,reshape(y1_full,[100,100]), 'EdgeColor','none','LineStyle','none','FaceLighting','phong');
scatter3(allx(:,1), allx(:,2), ally(:,1),'.k');
colormap cool;
alpha(.2);

subplot(1,2,2);
hold on;
surf(x1_full,x2_full,reshape(y2_full,[100,100]), 'EdgeColor','none','LineStyle','none','FaceLighting','phong');
scatter3(allx(:,1), allx(:,2), ally(:,2),'.k');
colormap cool;
alpha(.2);

%% 
close all;
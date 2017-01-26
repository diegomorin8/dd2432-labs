clear;

alpha = 0.9;
eta = 0.05;
hidden = 3;

x = eye(8) * 2 - 1;
[x_row, x_col] = size(x);
w = randn(hidden, x_row+1);
v = randn(x_row, hidden+1);
dw = 0;
dv = 0;

error = zeros(1,10000);
steps = 1:10000;
for i = steps
    % Forward pass
    hin = w * [x; ones(1, x_col)];
    hout = [phi(hin); ones(1, x_col)];

    oin = v * hout;
    out = phi(oin);

    % Backward pass
    delta_o = (out - x) .* phiprime(out);
    delta_h = (v' * delta_o) .* phiprime(hout);
    delta_h = delta_h(1:hidden, :);

    % Weight update
    dw = (dw .* alpha) - (delta_h * [x; ones(1, x_col)]') .* (1 - alpha);
    dv = (dv .* alpha) - (delta_o * hout') .* (1 - alpha);
    w = w + dw .* eta;
    v = v + dv .* eta;
    
    error(1,i) = sum(sum(abs(sign(out) - x) ./ 2));
    plot(steps, error);
    %pause(0.005)
end

% Forward pass
hin = w * [x; ones(1, x_col)];
hout = [phi(hin); ones(1, x_col)];

oin = v * hout;
out = phi(oin);

[~, human_readable_in] = max(x);
human_readable_hid = hout(1:3,:) > 0;
hid_strings = [];
for i = 1:8
    hid_strings = [hid_strings; num2str(human_readable_hid(:,i)')];
end
[~, human_readable_out] = max(out);
table(human_readable_in(:), hid_strings, human_readable_out(:), 'VariableNames', {'In', 'Hidden', 'Out'})
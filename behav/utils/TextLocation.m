function hOut = TextLocation(textString,varargin)

l = legend(textString,varargin{:});
t = annotation('textbox');
t.String = textString;
t.Position = l.Position;
delete(l);
t.LineStyle = 'None';
t.FontWeight = 'bold';
t.FontSize = 12;
t.FontName = 'Calibri';

if nargout
    hOut = t;
end
end
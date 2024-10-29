package cup.example;
import java_cup.runtime.ComplexSymbolFactory;
import java_cup.runtime.ComplexSymbolFactory.Location;
import java_cup.runtime.Symbol;
import java.lang.*;
import java.io.InputStreamReader;

%%

%class Lexer
%implements sym
%public
%unicode
%line
%column
%cup
%char
%{
	

    public Lexer(ComplexSymbolFactory sf, java.io.InputStream is){
		this(is);
        symbolFactory = sf;
    }
	public Lexer(ComplexSymbolFactory sf, java.io.Reader reader){
		this(reader);
        symbolFactory = sf;
    }
    
    private StringBuffer sb;
    private ComplexSymbolFactory symbolFactory;
    private int csline,cscolumn;

    public Symbol symbol(String name, int code){
		return symbolFactory.newSymbol(name, code,
						new Location(yyline+1,yycolumn+1, yychar), // -yylength()
						new Location(yyline+1,yycolumn+yylength(), yychar+yylength())
				);
    }
    public Symbol symbol(String name, int code, String lexem){
	return symbolFactory.newSymbol(name, code, 
						new Location(yyline+1, yycolumn +1, yychar), 
						new Location(yyline+1,yycolumn+yylength(), yychar+yylength()), lexem);
    }
    
    protected void emit_warning(String message){
    	System.out.println("scanner warning: " + message + " at : 2 "+ 
    			(yyline+1) + " " + (yycolumn+1) + " " + yychar);
    }
    
    protected void emit_error(String message){
    	System.out.println("scanner error: " + message + " at : 2" + 
    			(yyline+1) + " " + (yycolumn+1) + " " + yychar);
    }
%}

Newline    = \r | \n | \r\n
Whitespace = [ \t\f] | {Newline}
Number     = [0-9]+
RealNumber = [0-9]+(\.[0-9]+)?

/* comments */
Comment = {TraditionalComment} | {EndOfLineComment}
TraditionalComment = "/*" {CommentContent} \*+ "/"
EndOfLineComment = "//" [^\r\n]* {Newline}
CommentContent = ( [^*] | \*+[^*/] )*

/* identifiers */
alpha = [a-zA-Z]
digit = [0-9]
ID = {alpha}(_|{alpha}|{digit})*


%eofval{
    return symbolFactory.newSymbol("EOF",sym.EOF);
%eofval}

%state CODESEG


%%

<YYINITIAL> {


  {Whitespace} { /* skip whitespace */ }
  {Comment}    { /* skip comments */ }

/* Keywords */
  "var"        { return symbolFactory.newSymbol("VAR", VAR); }
  "fun"        { return symbolFactory.newSymbol("FUN", FUN); }
  "return"     { return symbolFactory.newSymbol("RETURN", RETURN); }
  "if"         { return symbolFactory.newSymbol("IF", IF); }
  "then"       { return symbolFactory.newSymbol("THEN", THEN); }
  "else"       { return symbolFactory.newSymbol("ELSE", ELSE); }
  "while"      { return symbolFactory.newSymbol("WHILE", WHILE); }
  "do"         { return symbolFactory.newSymbol("DO", DO); }
  "read"       { return symbolFactory.newSymbol("READ", READ); }
  "print"      { return symbolFactory.newSymbol("PRINT", PRINT); }
  "begin"      { return symbolFactory.newSymbol("BEGIN", BEGIN); }
  "end"        { return symbolFactory.newSymbol("END", END); }
  "int"        { return symbolFactory.newSymbol("INT", INT); }
  "real"       { return symbolFactory.newSymbol("REAL", REAL); }
  "bool"       { return symbolFactory.newSymbol("BOOL", BOOL); }
  "true"       { return symbolFactory.newSymbol("BVAL", BVAL, "true"); }
  "false"      { return symbolFactory.newSymbol("BVAL", BVAL, "false"); }
  "size"       { return symbolFactory.newSymbol("SIZE", SIZE); }
  "float"      { return symbolFactory.newSymbol("FLOAT", FLOAT); }
  "floor"      { return symbolFactory.newSymbol("FLOOR", FLOOR); }
  "ceil"       { return symbolFactory.newSymbol("CEIL", CEIL); }

/* Operators */
  "+"          { return symbolFactory.newSymbol("ADD", ADD); }
  "-"          { return symbolFactory.newSymbol("SUB", SUB); }
  "*"          { return symbolFactory.newSymbol("MUL", MUL); }
  "/"          { return symbolFactory.newSymbol("DIV", DIV); }
  "&&"         { return symbolFactory.newSymbol("AND", AND); }
  "||"         { return symbolFactory.newSymbol("OR", OR); }
  "not"        { return symbolFactory.newSymbol("NOT", NOT); }
  "="          { return symbolFactory.newSymbol("EQUAL", EQUAL); }
  "<"          { return symbolFactory.newSymbol("LT", LT); }
  ">"          { return symbolFactory.newSymbol("GT", GT); }
  "=<"         { return symbolFactory.newSymbol("LE", LE); }
  ">="         { return symbolFactory.newSymbol("GE", GE); }
  ":="         { return symbolFactory.newSymbol("ASSIGN", ASSIGN); }
  
/* Delimiters */
  "("          { return symbolFactory.newSymbol("LPAR", LPAR); }
  ")"          { return symbolFactory.newSymbol("RPAR", RPAR); }
  "{"          { return symbolFactory.newSymbol("CLPAR", CLPAR); }
  "}"          { return symbolFactory.newSymbol("CRPAR", CRPAR); }
  "["          { return symbolFactory.newSymbol("SLPAR", SLPAR); }
  "]"          { return symbolFactory.newSymbol("SRPAR", SRPAR); }
  ":"          { return symbolFactory.newSymbol("COLON", COLON); }
  ";"          { return symbolFactory.newSymbol("SEMICOLON", SEMICOLON); }
  ","          { return symbolFactory.newSymbol("COMMA", COMMA); }
  
/* Literals */
  {ID}         { return symbolFactory.newSymbol("ID", ID, yytext()); }
  {Number}     { return symbolFactory.newSymbol("IVAL", IVAL, Integer.parseInt(yytext())); }
  {RealNumber} { return symbolFactory.newSymbol("RVAL", RVAL, Double.parseDouble(yytext())); }
  
}

// error fallback
.|\n          { emit_warning("Unrecognized character '" +yytext()+"' -- ignored"); }

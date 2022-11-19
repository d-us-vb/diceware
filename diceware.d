import std.string : strip;
import std.format : formattedRead;
import std.stdio  : writeln, File, readln;
import std.random : uniform;
import std.regex  : matchAll;
import std.conv   : to;

void main()
{
    string dictionaryFile = "diceware.txt";
    
           
    writeln("Welcome to diceware password helper!\n" ~ "v0.1 by Jeremiah Glover, April, 2019.");
    File wordlist;
    wordlist.open(dictionaryFile, "r");

    string[] dicewords;
    
    // read word list file into a slice.
    int numLines;
    foreach (line; wordlist.byLine)
    {
        ++numLines;
        int dummy;
        string word;
        formattedRead(line, "%d\t%s", dummy, word);
        dicewords ~= word;
    }
    
    // the lowest value possible is 11111 in base six because dice start at 1, not 0.
    const int startVal = 1 * 6^^4 + 1 * 6^^3 + 1 * 6^^2 + 1 * 6; // = 1554 
    // leaving off the one because this will be used as an array index helper.
    
    const int maxVal = 6^^5; // 7776
    

    writeln("How many words would you like in your passphrase?");
    int num_words;
    while(true) {
      try {
        formattedRead(readln.strip, "%d", num_words);
        writeln("You may begin entering numbers from 1 and 6, pressing enter "
                ~ "after each.\n Your passphrase will be displayed immediately after "
                ~ "you enter that last");
        break;
      } catch(Exception e) {
        writeln("Please enter an integer.");
      }
    }
    int[] responses;
    for (int i; i < num_words; ++i)
    {
        int word_num = 0;
        for (int j; j < 5; ++j)
        {
            string holder = readln.strip;
            if(holder.length == 1 && matchAll(holder, `[1-6]{1}`))
            {
                word_num += to!int(holder) * 6 ^^ (4 - j);
            } else
            {
                --j;
                writeln("Please enter a number between 1 and 6.");
            }
        }
        writeln(word_num - startVal);
        responses ~= word_num - startVal;
    }
    writeln("Your passphrase is ");
    concatSelectedWords(dicewords, responses).writeln;

    //readln(); // clear input buffer.
    while (true)
    {
        writeln("Would you like a different password generated based on those");
        writeln("numbers? (y/n)");
        string quitvar = readln().strip;
        if (quitvar == "y")
        {
            int offset = uniform(0, maxVal);
            responses[0 .. $] = (responses[0 .. $] + offset) % maxVal;
            concatSelectedWords(dicewords, responses).writeln;
        }
        else if (quitvar == "n")
        {
            break;
        }
        else
        {
            writeln("please respond with y or n.");
        }
    }
}

string concatSelectedWords(string[] words, int[] selections)
{
    string concat;
    foreach (number; selections)
    {
        concat ~= words[number - 1] ~ " ";
    }
    return concat;
}


/** 
    this function is designed to be an intermediary between bases.
*/
string toDecimal(string number, int base)
{
    int[string] lits = 
    ["0" :  0, "1" :  1, "2" :  2, "3" :  3, 
     "4" :  4, "5" :  5, "6" :  6, "7" :  7, 
     "8" :  8, "9" :  9, "A" : 10, "B" : 11, 
     "C" : 12, "D" : 13, "E" : 14, "F" : 15];
    // validate input
    foreach(digit; number)
    {
        if(lits[to!string(digit)] >= base)
        {
            return "Error: '" ~ digit ~ "' is greater than or equal to base.";
        }
    }
    // a decimal number is composed of digits that are multiplied by a power of
    // ten corresponding to how many places from the right it appears in the
    // number. 1234 = 1 * 10^3 + 2 * 10^2 + 3 * 10^1 + 4 * 10^0;
    // to convert from any base into decimal, you multiply the decimal
    // representation of each digit times the decimal representation of the base
    // to the power of the position from the right taking the rightmost position
    // to be zero.
    int result;
    foreach(i, digit; number)
    {
        result += lits[to!string(digit)] * base^^(number.length - (i + 1));
        
    }
    return to!string(result);
}

unittest 
{
    assert(toDecimal("ABC", 6) == "Error, 'A' is greater than or equal to base.");
    assert(toDecimal("1234", 10) == "1234");
    assert(toDecimal("55555", 6) == "7776");
}

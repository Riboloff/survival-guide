#include <iostream>
#include <fstream>
#include <vector>
#include <map>
#include <random>

using namespace std;

map <int, char> mappingSymbols = {
    {-3, '+'},
    {-2, '-'},
    {-1, '|'},
};

const int X = 1;
const int Y = 0;

const int COEF_VERT_WALL = 5;
const int COEF_GOR_WALL = 5;

struct Point {
    int y;
    int x;
};

void printVectorDebug(const vector<int>& vec) {
    for (const int &v: vec) {
        if (v >= 0) {
            cout <<  v << " ";
        }
        else {
            //cout << mappingSymbols[v] << " ";
            cout << v << " ";
        }
    }
    cout << endl;
}

class LevelOfMap {
public:
    LevelOfMap() {};
    LevelOfMap(int len, LevelOfMap level_pre) {
        vector<int> str (len);

        vector<int> str_pre = level_pre.getHeader();
        vector<int> footer_pre = level_pre.getFooter();

        if (str_pre.size()) {
            for (int i = 0; i < str_pre.size(); i++) {
                if (footer_pre[i] == 0) {
                    str[i] = str_pre[i];
                }
            }
        }

        int inc = 1;
        for (int i = 0; i < str.size(); i++) {
            if (str[i]) {
                inc = str[i] + 1;
                continue;
            }

            if (i % 2 ) {
                str[i] = 0;
            }
            else {
                str[i] = inc;
                inc++;
            }
        }

        header = str;
    }

    void fill() {
        random_device rd;
        mt19937 mersenne(rd());
        for (int i = 0; i < header.size(); i++) {
            if (header[i] == 0 && (mersenne() % COEF_VERT_WALL == 0 || header[i-1] == header[i+1])) {
                header[i] = -1;
                unity(header, i);
            }
        }
        unity(header, header.size());

        footer = createFooter();
    }

    vector<int> getHeader() {
        return header;
    }
    vector<int> getFooter() {
        return footer;
    }

private:
    void unity(vector<int>& str, int pos_wall) {
        for (int j=pos_wall - 1; j > 0; j--) {
            if (str[j-1] == -1) {
                break;
            }
            str[j-1] = str[j];
        }
    }

    void createFooterWall(int start, int finish) {
        random_device rd;
        mt19937 mersenne(rd());
        int flag = 0;

        for (int i = start; i <= finish; i++) {
            if (footer[i] == -1) {
                footer[i] = -3;
                continue;
            }
            footer[i] = -2;

            if (mersenne() % COEF_GOR_WALL  == 0 || (flag == 0 && i == finish)) {
                footer[i] = 0;
                flag = 1;
            }
        }
    }

    vector<int> createFooter() {
         footer = header;

        int start = header.size() - 1;
        int finish = header.size() - 1;

        for (int i = header.size() - 1; i >= 0; i--) {
            if (header[i] == -1 || i == 0) {
                start = i + 1;
                createFooterWall(start - 1, finish);
                finish = i - 1;
            }
        }

        return footer;
    }

    vector<int> header;
    vector<int> footer;
};

class Map {
public:
    Map() {}


    void addLevel(LevelOfMap& level) {
        map.push_back(level.getHeader());
        map.push_back(level.getFooter());
    }

    vector<int> getSize() {
        return size;
    }

    void printLine(const vector<int>& vec) {
        for (const int &v: vec) {
            if (v >= 0) {
                cout <<  " ";
            }
            else {
                cout << mappingSymbols[v];
            }
        }
        cout << endl;
    }

    void printLine(const vector<int>& vec, ofstream& output) {
        for (const int &v: vec) {
            if (v >= 0) {
                output <<  " ";
            }
            else {
                output << mappingSymbols[v];
            }
        }
        output << endl;
    }

    void print() {
        for (const vector<int>& str: map) {
            printLine(str);
        }
    }

    void print(ofstream& output) {
        for (const vector<int>& str: map) {
            printLine(str, output);
        }
    }

    void addEmptyStr() {
        if (!map.size()) {
            return;
        }

        vector<int> str(map[0].size());
        for (auto& s: str) {
            s = 0;
        }
        map.push_back(str);
    }

    void createFrame() {
        vector<int> str;

        for (auto& m: map) {
            m.insert(m.begin(), 1, -1);
            m.push_back(-1);
        }

        for (int i = 0; i < map[0].size(); i++) {
            if (i == 0 || i == map[0].size() - 1) {
                str.push_back(-3);
            }
            else {
                str.push_back(-2);
            }
        }

        map.insert(map.begin(), {str.begin(), str.end()});
        map.push_back(str);
    }

    void afterCreate() {
        for (int y = 0; y < map.size(); y++) {
            for (int x = 0; x < map.size(); x++) {
                int symbol = map[y][x];
                int max_x = map[0].size();
                int max_y = map.size();

                pair<Point, bool> pp = getDownNeighbor(x, y, max_y - 1);
                if (pp.second) {
                    Point p = pp.first;
                    int s = map[p.y][p.x];
                    if (symbol == -2 && s == -1) {
                        symbol = map[y][x] = -3;
                    }
                }
            }
        }
    }

private:
    pair<Point, bool> getDownNeighbor(int x, int y, int max_y) {
        Point point;

        if (y + 1 > max_y) {
             return {{}, false};
        }

        pair<Point, bool> pa = {{y + 1, x}, true};
        return pa;
    }

    vector<Point> getGorNeighbors(int x, int y, int max_x, int max_y) {
        vector<Point> points;

        if (y - 1 >= 0) {
            points.push_back({y - 1, x});
        }
        if (y + 1 <= max_y) {
            points.push_back({y + 1, x});
        }

        return points;
    }

    vector<Point> getNeighbors(int x, int y, int max_x, int max_y) {
        int s_x = x - 1;
        int s_y = y - 1;

        int f_x = x + 1;
        int f_y = y + 1;

        vector<Point> neighbors;
        for (int i = s_y; i <= f_y; i++) {
            if (i < 0 || i > max_y) {
                continue;
            }

            for (int j = s_x; j <= f_x; j++) {
                if (j < 0 || j > max_x || (i == y && j == x)) {
                    continue;
                }

                neighbors.push_back({i, j});
            }
        }

        return neighbors;
    }

    vector<int> size;
    vector<vector<int>> map;
};

int main() {
    ofstream output("../map/second_map");

    const vector<int> size = {31, 81};
    Map map;
    LevelOfMap level_pre;

    for (int i = 0; i < size[Y] / 2; i++) {
        LevelOfMap level(size[X], level_pre);
        level.fill();

        map.addLevel(level);
    
        level_pre = level;
    }

    map.addEmptyStr();
    map.createFrame();
    map.afterCreate();

    map.print();
    map.print(output);

    return 0;
}

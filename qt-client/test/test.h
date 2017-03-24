#include <QtTest/QtTest>

class Table;

class TestCase : public QObject {
Q_OBJECT
private slots:
  void initTestCase();
  void cleanupTestCase();
  void testsomething_data();
  void testsomething();
  void rendercards_data();
  void rendercards();
  void animate();
  void renderChips_data();
  void renderChips();
  void simplegame();
  void render_bare_form_data();
  void render_bare_form();
  void render_login_form();
  void alignment_data();
  void alignment();
  void replayRecording_data();
  void replayRecording();
  void club_lobby();
private:
  void saveFrame(Table &tbl, QPixmap &image, int frame, QString format);
};

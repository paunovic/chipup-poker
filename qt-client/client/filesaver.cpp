#include <QNetworkReply>
#include <QDebug>
#include <QFile>
#include <QDir>
#include <QApplication>

#include "filesaver.h"
#include "pokermain.h"

FileSaver::FileSaver(QNetworkReply *reply, Core::UpdateFileInfo row) {
  this->reply = reply;
  this->row = row;
  connect(reply,SIGNAL(readyRead()),this,SLOT(readyRead()));
  QByteArray data = reply->readAll();
  //qDebug() << row.path << "read in x bytes:" << data.size() << "/" << row.size;
  QFile fh(row.path);
  QDir test(row.path);
  QFileInfo fh2(row.path);
  fh2.dir().remove(fh2.fileName());
  if (!test.exists()) {
    QDir parent(fh2.dir());
    if (!parent.exists()) {
      qDebug() << "parent doesnt exist" << parent << row.path;
      parent.mkpath(".");
    }
  }
  if (fh.open(QFile::WriteOnly)) {
    fh.write(data);
    fh.close();
    if (row.path == QApplication::applicationFilePath()) {
      fh.setPermissions(QFile::ExeOwner|QFile::ExeGroup|QFile::ExeOther|fh.permissions());
    }
    core->fileSaved(row);
    deleteLater(); // TODO, de-class?
  } else {
    qDebug() << "failed to open file";
  }
}

void FileSaver::readyRead() {
  qDebug() << row.path << "readyRead";
}

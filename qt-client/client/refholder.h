#pragma once

#include <QObject>
#include "tablestatus.h"

class RefHolder : public QObject {
Q_OBJECT
public:
	QSharedPointer<Data::TableStatus> ts;
};

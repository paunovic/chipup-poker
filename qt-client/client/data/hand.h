#ifndef DATA_HAND_H
#define DATA_HAND_H

#include <QObject>

#include "string"

namespace Data {

class Hand : public QObject {
Q_OBJECT
public:
	Hand(const std::string &in);

	Q_PROPERTY(QList<int> cards READ getCards)
private:
	QList<int> getCards();

	QList<int> cards;
};

} // namespace Data

#endif // DATA_HAND_H

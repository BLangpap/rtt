#include "NameServiceCollection.hpp"

using namespace RTT::Communication;

/**
 * @brief Constructor for a name service collection
 * 
 */
NameServiceCollection::NameServiceCollection() 
{
}

/**
 * @brief Destructor for a name service collection
 * 
 */
NameServiceCollection::~NameServiceCollection() {}

/**
 * @brief Adds a name service element to the collection.
 * 
 * @param NameService The name service element to add.
 * @return void
 */
void NameServiceCollection::add(INameService* pNameService)
{
  m_NameServiceCollection.push_back(pNameService);
}

/**
 * @brief Gets the beginning of the collection.
 * 
 * @return NameServiceIterator
 */
RTT::Communication::NameServiceCollection::NameServiceIterator NameServiceCollection::begin()
{
  return m_NameServiceCollection.begin();
}

/**
 * @brief Gets the end of the collection.
 * 
 * @return NameServiceIterator
 */
RTT::Communication::NameServiceCollection::NameServiceIterator NameServiceCollection::end()
{
  return m_NameServiceCollection.end();
}

RTT::Communication::NameServiceCollection::NameServiceCollectionSizeType NameServiceCollection::getSize()
{
  return m_NameServiceCollection.size();
}



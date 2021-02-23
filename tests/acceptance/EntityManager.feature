Feature: EntityManager
  In order to use Doctrine EntityManager safely
  As a Psalm user
  I need Psalm to typecheck EntityManager

  Background:
    Given I have the following config
      """
      <?xml version="1.0"?>
      <psalm totallyTyped="true">
        <projectFiles>
          <directory name="."/>
        </projectFiles>
        <plugins>
          <pluginClass class="Weirdan\DoctrinePsalmPlugin\Plugin" />
        </plugins>
      </psalm>
      """
    And I have the following code preamble
      """
      <?php
      use Doctrine\ORM\EntityRepository;
      use Doctrine\ORM\EntityManager;

      interface I {}

      /**
       * @psalm-suppress InvalidReturnType
       * @return EntityManager
       */
      function em() {}

      """
    # Psalm enables cache when there's a composer.lock file
    And I have empty composer.lock

  @EntityManager::getRepository
  Scenario: EntityManager returns specialized EntityRepository
    Given I have the following code
      """
      atan(em()->getRepository(I::class));
      """
    When I run Psalm
    Then I see these errors
      | Type            | Message                                                                     |
      | InvalidArgument | Argument 1 of atan expects float, Doctrine\ORM\EntityRepository<I> provided |
    And I see no other errors

  @EntityManager::getRepository
  Scenario: Getting repository for an invalid argument
    Given I have the following code
      """
      em()->getRepository(123);
      """
    When I run Psalm
    Then I see these errors
      | Type                  | Message                                                                                         |
      | InvalidScalarArgument | Argument 1 of Doctrine\ORM\EntityManager::getRepository expects class-string, 123 provided |
    And I see no other errors

  @EntityManager::find
  Scenario: Finding an entity
    Given I have the following code
      """
      atan(em()->find(I::class, 1));
      """
    When I run Psalm
    Then I see these errors
      | Type            | Message                                            |
      | InvalidArgument | Argument 1 of atan expects float, I\|null provided |
    And I see no other errors

  @EntityManager::find
  Scenario: Calling find with a wrong argument type
    Given I have the following code
      """
      em()->find(123, 1);
      """
    When I run Psalm
    Then I see these errors
      | Type                  | Message                                                                                |
      | InvalidScalarArgument | Argument 1 of Doctrine\ORM\EntityManager::find expects class-string, 123 provided |
    And I see no other errors

  @EntityManager::getReference
  Scenario: Getting a reference
    Given I have the following code
      """
      atan(em()->getReference(I::class, 1));
      """
    When I run Psalm
    Then I see these errors
      | Type            | Message                                            |
      | InvalidArgument | Argument 1 of atan expects float, I\|null provided |
    And I see no other errors

  @EntityManager::getReference
  Scenario: Calling getReference with a wrong argument type
    Given I have the following code
      """
      em()->getReference(123, 1);
      """
    When I run Psalm
    Then I see these errors
      | Type                  | Message                                                                                        |
      | InvalidScalarArgument | Argument 1 of Doctrine\ORM\EntityManager::getReference expects class-string, 123 provided |
    And I see no other errors

  @EntityManager::inheritance
  Scenario: Can extend EntityManager
    Given I have the following code
      """
      class MyManager extends EntityManager {}
      """
    When I run Psalm
    Then I see no errors

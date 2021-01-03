Feature: ObjectRepository
  In order to use Doctrine ObjectRepository safely
  As a Psalm user
  I need Psalm to typecheck ObjectRepository

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
      use Doctrine\Persistence\ObjectRepository;

      interface I {
        /** @return void */
        public function doThings();
      }
      /**
       * @template T
       * @param class-string<T> $entityClass
       * @return ObjectRepository<T>
       * @psalm-suppress InvalidReturnType
       */
      function repo(string $entityClass) {}

      /** @return void */
      function acceptsI(I $i) {}
      """
    # Psalm enables cache when there's a composer.lock file
    And I have empty composer.lock

  @ObjectRepository::find
  Scenario: Calling find returns typed object
    Given I have the following code
      """
      $i = repo(I::class)->find(123);
      if (null !== $i) {
        $i->doThings();
        acceptsI($i);
      }
      """
    When I run Psalm
    Then I see no errors

  @ObjectRepository::findAll
  Scenario: Calling findAll returns typed array
    Given I have the following code
      """
      foreach (repo(I::class)->findAll() as $i) {
        $i->doThings();
        acceptsI($i);
      }
      """
    When I run Psalm
    Then I see no errors

  @ObjectRepository::findBy
  Scenario: Calling findBy returns typed array
    Given I have the following code
      """
      foreach (repo(I::class)->findBy([]) as $i) {
        $i->doThings();
        acceptsI($i);
      }
      """
    When I run Psalm
    Then I see no errors

  @ObjectRepository::findOneBy
  Scenario: Calling findOneBy returns typed object
    Given I have the following code
      """
      $i = repo(I::class)->findOneBy([]);
      if (null !== $i) {
        $i->doThings();
        acceptsI($i);
      }
      """
    When I run Psalm
    Then I see no errors


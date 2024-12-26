import { entityKind } from "../../entity.cjs";
import type { TypedQueryBuilder } from "../../query-builders/query-builder.cjs";
import type { SingleStoreDialectConfig } from "../dialect.cjs";
import { SingleStoreDialect } from "../dialect.cjs";
import type { WithSubqueryWithSelection } from "../subquery.cjs";
import type { ColumnsSelection } from "../../sql/sql.cjs";
import { WithSubquery } from "../../subquery.cjs";
import { SingleStoreSelectBuilder } from "./select.cjs";
import type { SelectedFields } from "./select.types.cjs";
export declare class QueryBuilder {
    static readonly [entityKind]: string;
    private dialect;
    private dialectConfig;
    constructor(dialect?: SingleStoreDialect | SingleStoreDialectConfig);
    $with<TAlias extends string>(alias: TAlias): {
        as<TSelection extends ColumnsSelection>(qb: TypedQueryBuilder<TSelection> | ((qb: QueryBuilder) => TypedQueryBuilder<TSelection>)): WithSubqueryWithSelection<TSelection, TAlias>;
    };
    with(...queries: WithSubquery[]): {
        select: {
            (): SingleStoreSelectBuilder<undefined, never, "qb">;
            <TSelection extends SelectedFields>(fields: TSelection): SingleStoreSelectBuilder<TSelection, never, "qb">;
        };
        selectDistinct: {
            (): SingleStoreSelectBuilder<undefined, never, "qb">;
            <TSelection extends SelectedFields>(fields: TSelection): SingleStoreSelectBuilder<TSelection, never, "qb">;
        };
    };
    select(): SingleStoreSelectBuilder<undefined, never, 'qb'>;
    select<TSelection extends SelectedFields>(fields: TSelection): SingleStoreSelectBuilder<TSelection, never, 'qb'>;
    selectDistinct(): SingleStoreSelectBuilder<undefined, never, 'qb'>;
    selectDistinct<TSelection extends SelectedFields>(fields: TSelection): SingleStoreSelectBuilder<TSelection, never, 'qb'>;
    private getDialect;
}
